# Joy Kumagai and Fabio Favoretto
# Date: April 2021
# Creating the Index Figures 
# Habitat Protection Index Project

##### Load Packages ##### 
library(tidyverse)
library(sf)
library(rnaturalearth)
library(ggthemes)
library(patchwork)
library(ggpubr)
library(countrycode)

##### Load Habitat Protection Indexes ####

df <- read.csv("Data_final/habitat_protection_indexes.csv")

##### Overall Index Figures ####
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")
land <- ne_countries(scale = 110, returnclass = "sf")

## Projecting data
robin <-  "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m"
land <- st_transform(land, crs = robin)
eez_land <- st_transform(eez_land, crs = robin)

data <- df %>%
  group_by(UNION) %>% 
  summarise(G_Hs_P_I = mean(G_H_I, na.rm = T),
            L_Hs_P_I = mean(F_H_P, na.rm = T),
            T_Hs_I = mean(T_H_I, na.rm = T))

eez_land_global <- left_join(x = eez_land, y = data, by = "UNION") %>%  # Join the indicator data onto the eez_land 
  arrange(G_Hs_P_I)


# Supplementary Table I

data %>% 
  na.omit() %>% 
  arrange(-T_Hs_I) %>% 
  magrittr::set_colnames(c("Jurisdiction", "GHPI", "LHPI", "THPI")) %>% 
  write.csv(., "Tables/supplementary_tableI.csv", row.names = F)

rm(data)

###### Habitat Specific Figures #####
habitats <- c("coldcorals", "coralreefs", "knolls_seamounts", "mangroves", "saltmarshes", "seagrasses")

for (i in 1:length(habitats)) {
  data <- df %>% filter(habitat == habitats[i]) 
  
  hab_correct <- "correct this"
  if (habitats[i] == "coldcorals") {hab_correct <- "Cold Corals"}
  if (habitats[i] == "coralreefs") {hab_correct <- "Warm Water Corals"}
  if (habitats[i] == "knolls_seamounts") {hab_correct <- "Knolls & Seamounts"}
  if (habitats[i] == "mangroves") {hab_correct <- "Mangroves"}
  if (habitats[i] == "saltmarshes") {hab_correct <- "Saltmarsh"}
  if (habitats[i] == "seagrasses") {hab_correct <- "Seagrasses"}
  
  
  eez_land_in_loop <- left_join(x = eez_land, y = data, by = "UNION") %>%  # Join the indicator data onto the eez_land 
    arrange(G_H_I)
  
  
  grid <- st_graticule(lat = seq(-90, 90, by = 30),
                       lon = seq(-180, 180, by = 60)) %>% 
    st_transform("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m") %>% 
    st_geometry 
  
  p1 <- ggplot(eez_land_in_loop) +
    geom_sf(aes(fill = G_H_I, colour = " ")) +
    geom_sf(data = grid,
            colour = "gray80", 
            linetype = "dashed") +
    geom_sf(data = land, 
            col = NA,
            fill = "gray90") +
    annotate("text", x = -18000000, y = 0, label = "0°", size = 3) +
    annotate("text", x = -18000000, y = 3200000, label = "30° N", size = 3) +
    annotate("text", x = -15500000, y = 6200000, label = "60° N", size = 3) +
    annotate("text", x = -18000000, y = -3200000, label = "30° S", size = 3) +
    annotate("text", x = -15500000, y = -6200000, label = "60° S", size = 3) +
    annotate("text", x = 0, y = 9500000, label = "0°", size = 3) +
    annotate("text", x = -3000000, y = 9500000, label = "60°W", size = 3) +
    annotate("text", x = 3000000, y = 9500000, label = "60°E", size = 3) +
    annotate("text", x = -8000000, y = 9500000, label = "180°W", size = 3) +
    annotate("text", x = 8000000, y = 9500000, label = "180°E", size = 3) +
    scale_fill_gradient2(
      low = "#f0f9e8",
      mid = "#7bccc4",
      high = "#0868ac",
      midpoint = median(eez_land_in_loop$G_H_I, na.rm = T),
      space = "Lab",
      na.value = "black",
      aesthetics = "fill",
      n.breaks = 5, 
      guide = guide_colorbar(title.position = "top",
                             title.hjust = .5,
                             barwidth = 10, 
                             barheight = 0.5
      )) +
    scale_colour_manual(values = NA) +              
    guides(colour = guide_legend("No data", override.aes = list(colour = "black", fill = "black"))) + 
    
    labs(fill = paste0("GHPI for ", hab_correct)) +
    theme(panel.background = element_blank(), 
          axis.text.x = element_text(size = 12),
          axis.title = element_blank(),
          legend.position = "bottom")
  
  p2 <- ggplot(eez_land_in_loop) +
    geom_sf(aes(fill = F_H_P, colour = " ")) +
    geom_sf(data = grid,
            colour = "gray80", 
            linetype = "dashed") +
    geom_sf(data = land, 
            col = NA,
            fill = "gray90") +
    annotate("text", x = -18000000, y = 0, label = "0°", size = 3) +
    annotate("text", x = -18000000, y = 3200000, label = "30° N", size = 3) +
    annotate("text", x = -15500000, y = 6200000, label = "60° N", size = 3) +
    annotate("text", x = -18000000, y = -3200000, label = "30° S", size = 3) +
    annotate("text", x = -15500000, y = -6200000, label = "60° S", size = 3) +
    annotate("text", x = 0, y = 9500000, label = "0°", size = 3) +
    annotate("text", x = -3000000, y = 9500000, label = "60°W", size = 3) +
    annotate("text", x = 3000000, y = 9500000, label = "60°E", size = 3) +
    annotate("text", x = -8000000, y = 9500000, label = "180°W", size = 3) +
    annotate("text", x = 8000000, y = 9500000, label = "180°E", size = 3) +
    scale_fill_gradient2(
      low = "#f0f9e8",
      mid = "#7bccc4",
      high = "#0868ac",
      midpoint = 0.5,
      space = "Lab",
      na.value = "black",
      aesthetics = "fill",
      n.breaks = 5, 
      guide = guide_colorbar(title.position = "top",
                             title.hjust = .5,
                             barwidth = 10, 
                             barheight = 0.5
      )) +
    scale_colour_manual(values = NA) +              
    guides(colour = guide_legend("No data", override.aes = list(colour = "black", fill = "black"))) + 
    
    labs(fill = paste0("LHPI for ", hab_correct)) +
    theme(panel.background = element_blank(), 
          axis.text.x = element_text(size = 12),
          axis.title = element_blank(),
          legend.position = "bottom")
  p3 <- p1 / p2 +
    plot_annotation(tag_levels = 'A')
  
  ggsave(plot = p3, filename = paste0("Figures/supplementary_figure_", hab_correct, "global_local.png"), dpi = 600, height = 8, width = 7)
  
  data1 <- data %>% 
    slice_max(order_by = T_H_I, n = 10) 
  
  data2 <- data %>% 
    slice_min(order_by = T_H_I, n = 10)
  
  data <- rbind(data1, data2)
  
  
 p4 <-  data %>% 
    na.omit() %>% 
    ggplot(aes(x = reorder(UNION, T_H_I), y = T_H_I)) +
    geom_bar(stat = 'identity', aes(fill = T_H_I > 0), position = 'dodge', col = 'transparent') +
    theme_bw() +
    scale_fill_manual(guide = 'none',
                      values = c("red3", "#0868ac")) +
    labs(x = "Jurisdictions", y = paste0("Targeted GHPI for ", hab_correct) ) +
    theme(axis.text.x = element_text(angle = 90, vjust = .5))
 
  
  ggsave(p4, filename = paste0("Figures/supplementary_figure_bar_plot_", hab_correct, ".png"), dpi = 300, height = 8, width = 8)
  
}
