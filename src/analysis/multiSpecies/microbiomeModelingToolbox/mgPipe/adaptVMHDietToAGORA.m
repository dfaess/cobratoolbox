function [adaptedDiet, growthOK] = adaptVMHDietToAGORA(VMHDiet, setupUsed, AGORAPath)
% Part of the Microbiome Modeling Toolbox.
% This function adapts a diet generated by the Diet Designer on
% https://vmh.uni.lu such that microbiome community models created from the
% AGORA resource can generate biomass. All metabolites required by at least
% one AGORA model are added. Note that the adapted diet that is the output
% of this function is specific to the AGORA resource. It is not guaranteed
% that other constraint-based models can produce biomass on this diet.
% Units are given in mmol/day/person.
%
% USAGE:
%
%    [adaptedDietConstraints, growthOK] = adaptVMHDietToAGORA(VMHDiet, setupUsed, AGORAPath)
%
% INPUTS:
%    VMHDietConstraints:     Name of text file with VMH exchange reaction IDs
%                            and values on lower bounds generated by Diet
%                            Designer on https://vmh.uni.lu (or manually).
%    setupUsed:              Model setup for which the adapted diet will be
%                            used. Allowed inputs are AGORA (the single AGORA
%                            models), Pairwise (the microbe-microbe models
%                            generated by the pairwise modeling module), and
%                            Microbiota (the microbe community models
%                            generated by MgPipe).
%
% OPTIONAL INPUTS:
%     AGORAPath:             Path to the AGORA model resource. If entered,
%                            growth of all single models on the adapted diet
%                            will be tested.
%
% OUTPUT:
%     adaptedDiet:           Cell array of exchange reaction IDs, values on
%                            lower bounds, and values on upper bounds that
%                            can serve as input for the function useDiet.
%
% OPTIONAL OUTPUT:
%     growthOK:              Variable indicating whether all AGORA models could
%                            grow on the adapted diet (if 1 then yes).
%
% .. Authors:
%       - Almut Heinken & Ines Thiele, 03/2018

VMHDietConstraints = readtable(strcat(VMHDiet, '.txt'), 'Delimiter', '\t');  % load the text file with the diet
VMHDietConstraints = table2cell(VMHDietConstraints);
% Start modification of the entered diet
adaptedDietConstraints = VMHDietConstraints;
for i = 1:length(adaptedDietConstraints)
    adaptedDietConstraints{i, 2} = num2str(-(VMHDietConstraints{i, 2}));
end

% Define the list of metabolites required by at least one AGORA model for
% growth
essentialMetabolites = {'EX_12dgr180(e)'; 'EX_26dap_M(e)'; 'EX_2dmmq8(e)'; 'EX_2obut(e)'; 'EX_3mop(e)'; 'EX_4abz(e)'; 'EX_4hbz(e)'; 'EX_ac(e)'; 'EX_acnam(e)'; 'EX_acgam(e)'; 'EX_acmana(e)'; 'EX_ade(e)'; 'EX_adn(e)'; 'EX_adocbl(e)'; 'EX_adpcbl(e)'; 'EX_ala_D(e)'; 'EX_ala_L(e)'; 'EX_amet(e)'; 'EX_amp(e)'; 'EX_arab_D(e)'; 'EX_arg_L(e)'; 'EX_asn_L(e)'; 'EX_btn(e)'; 'EX_ca2(e)'; 'EX_cbl1(e)'; 'EX_cgly(e)'; 'EX_chor(e)'; 'EX_chsterol(e)'; 'EX_cit(e)'; 'EX_cl(e)'; 'EX_cobalt2(e)'; 'EX_csn(e)'; 'EX_cu2(e)'; 'EX_cys_L(e)'; 'EX_cytd(e)'; 'EX_dad_2(e)'; 'EX_dcyt(e)'; 'EX_ddca(e)'; 'EX_dgsn(e)'; 'EX_fald(e)'; 'EX_fe2(e)'; 'EX_fe3(e)'; 'EX_fol(e)'; 'EX_for(e)'; 'EX_gal(e)'; 'EX_glc_D(e)'; 'EX_gln_L(e)'; 'EX_glu_L(e)'; 'EX_gly(e)'; 'EX_glyc(e)'; 'EX_glyc3p(e)'; 'EX_gsn(e)'; 'EX_gthox(e)'; 'EX_gthrd(e)'; 'EX_gua(e)'; 'EX_h(e)'; 'EX_h2o(e)'; 'EX_h2s(e)'; 'EX_his_L(e)'; 'EX_hxan(e)'; 'EX_ile_L(e)'; 'EX_k(e)'; 'EX_lanost(e)'; 'EX_leu_L(e)'; 'EX_lys_L(e)'; 'EX_malt(e)'; 'EX_met_L(e)'; 'EX_mg2(e)'; 'EX_mn2(e)'; 'EX_mqn7(e)'; 'EX_mqn8(e)'; 'EX_nac(e)'; 'EX_ncam(e)'; 'EX_nmn(e)'; 'EX_no2(e)'; 'EX_ocdca(e)'; 'EX_ocdcea(e)'; 'EX_orn(e)'; 'EX_phe_L(e)'; 'EX_pheme(e)'; 'EX_pi(e)'; 'EX_pnto_R(e)'; 'EX_pro_L(e)'; 'EX_ptrc(e)'; 'EX_pydx(e)'; 'EX_pydxn(e)'; 'EX_q8(e)'; 'EX_rib_D(e)'; 'EX_ribflv(e)'; 'EX_ser_L(e)'; 'EX_sheme(e)'; 'EX_so4(e)'; 'EX_spmd(e)'; 'EX_thm(e)'; 'EX_thr_L(e)'; 'EX_thymd(e)'; 'EX_trp_L(e)'; 'EX_ttdca(e)'; 'EX_tyr_L(e)'; 'EX_ura(e)'; 'EX_val_L(e)'; 'EX_xan(e)'; 'EX_xyl_D(e)'; 'EX_zn2(e)'};

% Add essential metabolites not yet included in the entered diet
MissingUptakes = setdiff(essentialMetabolites, VMHDietConstraints(:, 1));
% add the missing exchange reactions to the adapted diet
CLength = size(adaptedDietConstraints, 1);
for i = 1:length(MissingUptakes)
    adaptedDietConstraints{CLength + i, 1} = MissingUptakes{i};
    adaptedDietConstraints{CLength + i, 2} = num2str(-0.1);
end

% Allow uptake of certain dietary compounds that are currently not mapped in the
% Diet Designer
CLength = size(adaptedDietConstraints, 1);
UnmappedCompounds = {'EX_asn_L(e)';'EX_gln_L(e)';'EX_crn(e)';'EX_elaid(e)';'EX_hdcea(e)';'EX_dlnlcg(e)';'EX_adrn(e)';'EX_hco3(e)';'EX_sprm(e)'; 'EX_carn(e)';'EX_7thf(e)';'EX_Lcystin(e)';'EX_hista(e)';'EX_orn(e)';'EX_ptrc(e)';'EX_creat(e)';'EX_cytd(e)';'EX_so4(e)'};
UnmappedCompounds = setdiff(UnmappedCompounds, VMHDietConstraints(:, 1));
for i = 1:length(UnmappedCompounds)
    adaptedDietConstraints{CLength + i, 1} = UnmappedCompounds{i};
    adaptedDietConstraints{CLength + i, 2} = num2str(-50);
end

% based on a daily intake of 396 mg in Av Am Diet per day (Sahoo 2013 paper)
CLength = size(adaptedDietConstraints, 1);
adaptedDietConstraints{CLength + 1, 1} = 'EX_chol(e)';
adaptedDietConstraints{CLength + 1, 2} = '-41.251';

% Increase the uptake rate of micronutrients with too low defined uptake
% rates to sustain microbiota model growth (below 1e-6 mol/day/person).
% Lower bounds will be relaxed by factor 100 if allowed uptake is below 0.1 mmol*gDW-1*hr-1.
% Also no uptake is enforced.
micronutrients ={'EX_adocbl(e)';'EX_vitd2(e)';'EX_vitd3(e)';'EX_psyl(e)';'EX_gum(e)';'EX_bglc(e)';'EX_phyQ(e)';'EX_fol(e)';'EX_5mthf(e)';'EX_q10(e)';'EX_retinol_9_cis(e)';'EX_pydxn(e)';'EX_pydam(e)';'EX_pydx(e)';'EX_pheme(e)';'EX_ribflv(e)';'EX_thm(e)';'EX_avite1(e)';'EX_pnto_R(e)''EX_na1(e)';'EX_cl(e)';'EX_k(e)';'EX_pi(e)';'EX_zn2(e)';'EX_cu2(e)'};

for i = 1:  size(adaptedDietConstraints,1)
    % exception for micronutrients to avoid numberical issues
    if ~isempty(find(ismember(micronutrients,adaptedDietConstraints{i,1}))) && abs(str2double(adaptedDietConstraints{i,2}))<=0.1
        adaptedDietConstraints{i,2} = num2str(str2double(adaptedDietConstraints{i,2})*100);
    end
end

% If the path to AGORA models was entered: test growth of each model on the
% adapted diet.
if nargin > 2
    fprintf('Testing growth of AGORA on the diet... \n')
    % set a solver if not done yet
    global CBT_LP_SOLVER
    solver = CBT_LP_SOLVER;
    if isempty(solver)
        initCobraToolbox;
    end
    % inconsistency in reaction IDs..can currently only be fixed manually.
    TestAdaptedDietConstraints = adaptedDietConstraints;
    TestAdaptedDietConstraints(:, 1) = strrep(TestAdaptedDietConstraints(:, 1), 'EX_adocbl(e)', 'EX_adpcbl(e)');
    % list the AGORA models
    modelList = cellstr(ls([AGORAPath, '*.mat']));
    for i = 1:length(modelList)
        load([AGORAPath, modelList{i}])
        model = useDiet(model, TestAdaptedDietConstraints);
        bioID = model.rxns(find(strncmp(model.rxns, 'biomass', 7)));
        model = changeObjective(model, bioID);
        FBA = optimizeCbModel(model, 'max');
        if FBA.f > 0.00001
            growthOK(i,1) = 1;
        else
            growthOK(i,1) = 0;
        end
    end
    if sum(growthOK) == length(growthOK)
        fprintf('All AGORA models can grow on the diet. \n')
    else
        fprintf('Not all AGORA models can grow on the diet. \n')
    end
end

% Adapt exchange eaction IDs to the desired setup (single models or
% microbiota models) by converting exchange reaction IDs. For the
% microbiota setup, upper bounds are also constrained to enforce a certain
% uptake of metabolites.
if strcmp(setupUsed, 'AGORA')
    % inconsistency in reaction IDs..can currently only be fixed manually.
    adaptedDietConstraints(:, 1) = strrep(adaptedDietConstraints(:, 1), 'EX_adocbl(e)', 'EX_adpcbl(e)');
elseif strcmp(setupUsed, 'Pairwise')
    adaptedDietConstraints(:, 1) = regexprep(adaptedDietConstraints(:, 1), '\(e\)', '\[u\]');
elseif strcmp(setupUsed, 'Microbiota')
    % add constraints on upper bounds based on uptake constraints in the
    % diet
    for i = 1:size(adaptedDietConstraints, 1)
        adaptedDietConstraints{i, 3} = '0';
        origDietConstr=find(strcmp(adaptedDietConstraints{i, 1},VMHDietConstraints(:,1)));
        if ~isempty(origDietConstr)
            adaptedDietConstraints{i, 3} = num2str(-0.8 * VMHDietConstraints{origDietConstr, 2});
        end
    end
    adaptedDietConstraints(:, 1) = regexprep(adaptedDietConstraints(:, 1), 'EX_', 'Diet_EX_');
    adaptedDietConstraints(:, 1) = regexprep(adaptedDietConstraints(:, 1), '\(e\)', '\[d\]');
else
    fprintf('Setup entered not recognized! \n')
end
adaptedDietConstraints(:, 1) = cell(adaptedDietConstraints(:, 1));
adaptedDiet = adaptedDietConstraints;
end
