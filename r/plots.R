library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)

setwd("/Users/zhuqin/Desktop/CMML/analysis")

dir.create("figures", showWarnings = FALSE)

# ========= Read XVG =========
read_xvg <- function(file, yname = "value") {
  lines <- readLines(file)
  lines <- lines[!grepl("^[@#]", lines)]
  df <- read.table(text = lines, header = FALSE)
  colnames(df) <- c("Time_ps", yname)
  return(df)
}

# ========= Read chain B RMSD =========
rmsd_280 <- read_xvg("rmsd_280_chainB_true.xvg", "RMSD")
rmsd_300 <- read_xvg("rmsd_300_chainB_true.xvg", "RMSD")
rmsd_320 <- read_xvg("rmsd_320_chainB_true.xvg", "RMSD")

rmsd_280$Temperature <- "280 K"
rmsd_300$Temperature <- "300 K"
rmsd_320$Temperature <- "320 K"

rmsd_all <- bind_rows(rmsd_280, rmsd_300, rmsd_320) %>%
  mutate(Time_ns = Time_ps / 1000)

# ========= Plot RMSD =========
p_rmsd <- ggplot(rmsd_all, aes(x = Time_ns, y = RMSD, color = Temperature)) +
  geom_line(linewidth = 0.9) +
  labs(
    x = "Time (ns)",
    y = "Chain B RMSD (nm)",
    title = "RMSD of ECs1815 (chain B) at different temperatures"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "bottom"
  )

ggsave("figures/chainB_RMSD_all_temperatures.png", p_rmsd, width = 7, height = 5, dpi = 300)

# ========= Read chain B Rg =========
rg_280 <- read_xvg("gyrate_280_chainB_true.xvg", "Rg")
rg_300 <- read_xvg("gyrate_300_chainB_true.xvg", "Rg")
rg_320 <- read_xvg("gyrate_320_chainB_true.xvg", "Rg")

rg_280$Temperature <- "280 K"
rg_300$Temperature <- "300 K"
rg_320$Temperature <- "320 K"

rg_all <- bind_rows(rg_280, rg_300, rg_320) %>%
  mutate(Time_ns = Time_ps / 1000)

# ========= Plot Rg =========
p_rg <- ggplot(rg_all, aes(x = Time_ns, y = Rg, color = Temperature)) +
  geom_line(linewidth = 0.9) +
  labs(
    x = "Time (ns)",
    y = "Chain B radius of gyration (nm)",
    title = "Radius of gyration of ECs1815 (chain B) at different temperatures"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "bottom"
  )

ggsave("figures/chainB_Rg_all_temperatures.png", p_rg, width = 7, height = 5, dpi = 300)

# ========= Read summary table =========
summary_table <- read.csv("summary_table.csv", check.names = FALSE)

# ========= Keep only MD structures for temperature-dependent plots =========
md_summary <- summary_table %>%
  filter(Structure %in% c("280 K MD", "300 K MD", "320 K MD")) %>%
  mutate(Temperature = factor(Structure, levels = c("280 K MD", "300 K MD", "320 K MD")))

# ========= Plot H-bonds =========
p_hbond <- ggplot(md_summary, aes(x = Temperature, y = `Interface H-bonds`, fill = Temperature)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = `Interface H-bonds`), vjust = -0.3, size = 5) +
  labs(
    x = "Temperature",
    y = "Interface H-bonds",
    title = "Interfacial hydrogen bonds"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "none"
  )

ggsave("figures/Hbonds_barplot.png", p_hbond, width = 6, height = 5, dpi = 300)

# ========= Plot Interface area =========
p_pisa <- ggplot(md_summary, aes(x = Temperature, y = `Interface area (Å²)`, fill = Temperature)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = round(`Interface area (Å²)`, 1)), vjust = -0.3, size = 5) +
  labs(
    x = "Temperature",
    y = expression("Total interface area ("*A^2*")"),
    title = "PISA interface area"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "none"
  )

ggsave("figures/PISA_interface_area_barplot.png", p_pisa, width = 6, height = 5, dpi = 300)

# ========= Ramachandran barplot (MD + AlphaFold) =========
rama_long <- summary_table %>%
  transmute(
    Structure,
    Favoured = `Favoured (%)`,
    Disallowed = (`Outliers` / ifelse(Structure == "280 K MD", 396,
                                      ifelse(Structure == "300 K MD", 398,
                                             ifelse(Structure == "320 K MD", 398, 437)))) * 100
  ) %>%
  mutate(Allowed = 100 - Favoured - Disallowed) %>%
  pivot_longer(cols = c(Favoured, Allowed, Disallowed),
               names_to = "Category",
               values_to = "Percent")

rama_long$Category <- factor(
  rama_long$Category,
  levels = c("Favoured", "Allowed", "Disallowed")
)

p_rama <- ggplot(rama_long, aes(x = Structure, y = Percent, fill = Category)) +
  geom_col() +
  labs(
    x = "Structure",
    y = "Residues (%)",
    title = "Ramachandran statistics"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 15, hjust = 1)
  )

ggsave("figures/Ramachandran_barplot.png", p_rama, width = 8, height = 5, dpi = 300)

# ========= Pathogen secondary structure =========
pathogen_ss <- summary_table %>%
  select(Structure, `Pathogen helix (%)`, `Pathogen loop (%)`) %>%
  pivot_longer(cols = c(`Pathogen helix (%)`, `Pathogen loop (%)`),
               names_to = "StructureType",
               values_to = "Percent")

pathogen_ss$StructureType <- factor(
  pathogen_ss$StructureType,
  levels = c("Pathogen helix (%)", "Pathogen loop (%)"),
  labels = c("Helix", "Loop")
)

p_pathogen_ss <- ggplot(pathogen_ss, aes(x = Structure, y = Percent, fill = StructureType)) +
  geom_col(position = "dodge", width = 0.65) +
  labs(
    x = "Structure",
    y = "Percentage (%)",
    title = "Secondary structure of pathogen chain B"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 15, hjust = 1)
  )

ggsave("figures/Pathogen_secondary_structure.png", p_pathogen_ss, width = 8, height = 5, dpi = 300)

cat("Done. Outputs saved in analysis/figures/\n")
