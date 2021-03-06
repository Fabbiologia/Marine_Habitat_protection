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

##### Load Habitat Protection Indexes ####

df <- read.csv("Data_final/habitat_protection_indexes.csv")

##### Overal Index Figures ####
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

grid <- st_graticule(lat = seq(-90, 90, by = 30),
                     lon = seq(-180, 180, by = 60)) %>% 
        st_transform("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m") %>% 
        st_geometry 

plot1 <- ggplot(eez_land_global) +
        geom_sf(aes(fill = G_Hs_P_I, colour = " ")) +
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
                midpoint = .025,
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
        labs(fill = "Global Habitat Protection Index (average)") +
        theme(panel.background = element_blank(), 
              axis.text.x = element_text(size = 12),
              axis.title = element_blank(),
              legend.position = "bottom")

plot2 <- ggplot(eez_land_global) +
        geom_sf(aes(fill = L_Hs_P_I, colour = " ")) +
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
        
        labs(fill = "Local Habitat Protection Index (average)") +
        theme(panel.background = element_blank(), 
              axis.text.x = element_text(size = 12),
              axis.title = element_blank(),
              legend.position = "bottom")

plot1 / plot2 +
        plot_annotation(tag_levels = 'A')

ggsave(plot = last_plot(), filename = "Figures/Global_and_local_protection_index_average.png", dpi = 600, height = 8, width = 8)
ggsave(plot = plot1, filename = "Figures/figure2.png", dpi = 600, height = 5, width = 8)


