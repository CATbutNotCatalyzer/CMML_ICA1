setwd("/Users/zhuqin/Desktop/CMML/analysis/figures")

library(png)
library(grid)
library(ggplot2)
library(patchwork)

img_to_plot <- function(file) {
  img <- readPNG(file)
  g <- rasterGrob(img, interpolate = TRUE)
  ggplot() +
    annotation_custom(g, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    theme_void()
}

# Figure 1
p1 <- img_to_plot("chainB_RMSD_all_temperatures.png")
p2 <- img_to_plot("chainB_Rg_all_temperatures.png")

fig1 <- p1 + p2 +
  plot_annotation(tag_levels = "A") &
  theme(
    plot.tag = element_text(size = 20, face = "bold"),
    plot.tag.position = c(0.02, 0.98)
  )

ggsave("Figure1_combined.png", fig1, width = 12, height = 5, dpi = 300)

# Figure 2
p_overlay <- img_to_plot("overlay.png")
p_pisa <- img_to_plot("PISA_interface_area_barplot.png")
p_hbond <- img_to_plot("Hbonds_barplot.png")

fig2 <- p_overlay + (p_pisa / p_hbond) +
  plot_annotation(tag_levels = "A") &
  theme(
    plot.tag = element_text(size = 20, face = "bold"),
    plot.tag.position = c(0.02, 0.98)
  )

ggsave("Figure2_combined.png", fig2, width = 12, height = 8, dpi = 300)
