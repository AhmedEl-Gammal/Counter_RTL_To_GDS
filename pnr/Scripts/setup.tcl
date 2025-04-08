# ================================================ #
# ================== Search path ================= #
# ================================================ #
set_app_var search_path /home/ICer/Downloads/Lib

# ================================================ #
# ================== NDM_library ================= #
# ================================================ #
set reference_library /home/ICer/Desktop/Intake45_Elgammal/Counter/pnr/ndm/saed90nm_max.ndm

# ================================================ #
# =================== Techfile =================== #
# ================================================ #
set TECH_FILE $search_path/process/astro/tech/astroTechFile.tf 

# ================================================ #
# ================ Design Library ================ #
# ================================================ #
create_lib -technology $TECH_FILE -ref_libs $reference_library counter.dlib

# ================================================ #
# ================== Load Design ================= #
# ================================================ #
read_verilog -top counter ../../dft/output/counter_dft_compiled_1ch.v
# ----------- Read_SDC ----------- #
read_sdc ../../syn/output/counter.sdc
# -----------  Linking ----------- #
link_block


# ================================================ #
# ===================== TLU+ ===================== #
# ================================================ #
set Tech $search_path/Technology_Kit/starrcxt

read_parasitic_tech -layermap $Tech/tech2itf.map -tlup $Tech/tluplus/saed90nm_1p9m_1t_Cmax.tluplus  -name maxTLU

read_parasitic_tech -layermap $Tech/tech2itf.map -tlup $Tech/tluplus/saed90nm_1p9m_1t_Cmin.tluplus  -name minTLU

set_parasitic_parameters -late_spec maxTLU -early_spec minTLU




# ================================================ #
# =================== End_Step =================== #
# ================================================ #
save_block -as counter_setup counter.dlib:counter.design




