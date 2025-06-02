#### Load required packages to extend R's functionality for data wrangling, visualization, and spatial data handling
library(sf)        # For handling spatial vector data (e.g., shapefiles)
library(dplyr)     # For data manipulation (e.g., filter, select, summarise)
library(tidyr)     # For reshaping data (e.g., pivot_longer)
library(ggplot2)   # For creating plots

#### Step 1: Download economic CSV data from Zenodo

# Create folders for data and plots if they don't already exist
dir.create("data", recursive = TRUE, showWarnings = FALSE)
dir.create("plots", recursive = TRUE, showWarnings = FALSE)

# Define download URL and destination path for the CSV file
url <- "https://zenodo.org/records/10939644/files/NUTS2_EU_economic_LAMASUS.csv?download=1"
destfile <- "data/NUTS2_EU_economic_LAMASUS.csv"

# Download the CSV file in binary mode to avoid encoding issues
download.file(url, destfile, mode = "wb")

# Load the CSV into a data frame
data <- read.csv(file = destfile)

# Show a statistical summary of the dataset
summary(data)

#### Step 2: Process employment data by sector

# Select relevant columns: region, year, and employment measures
sect.emp <- data %>%
  dplyr::select(NUTS, year, empl, starts_with("emp_"))

# Filter for decadal years and calculate sector shares (percent of total employment)
sect.emp <- sect.emp %>%
  filter(year %in% seq(1980, 2020, 10)) %>%
  group_by(NUTS, year) %>%
  summarise(across(everything(), ~mean(./empl * 100, na.rm = TRUE)))

# Summarize processed employment shares
summary(sect.emp)

# Reshape to long format for plotting: one row per NUTS x year x sector
sect.emp.long <- sect.emp %>%
  pivot_longer(cols = starts_with("emp_"),
               names_to = "sector",
               values_to = "employment") %>%
  mutate(year = as.factor(year))  # Convert year to factor for ggplot

# Plot density curves of employment in Sector A by year
ggplot(sect.emp.long %>% filter(sector == "emp_A"), aes(x = employment, fill = year)) +
  geom_density(alpha = 0.4) +
  theme_minimal() +
  xlim(0, 30) +
  labs(
    title = "Density Plot of Employment in Sector A by Year",
    x = "Percent of jobs in agricultural sector",
    y = "Density"
  )

# Save the plot
ggsave(last_plot(), file = "plots/emp_density.png", height = 6, width = 8)

#### Step 3: Repeat the same steps for Gross Value Added (GVA)

# Select region, year, and GVA columns
sect.gva <- data %>%
  dplyr::select(NUTS, year, gdp, starts_with("gva_"))

# Filter for decadal years and calculate sector shares (percent of total GDP)
sect.gva <- sect.gva %>%
  filter(year %in% seq(1980, 2020, 10)) %>%
  group_by(NUTS, year) %>%
  summarise(across(everything(), ~mean(./gdp * 100, na.rm = TRUE)))

# Summarize processed GVA shares
summary(sect.gva)

# Reshape to long format for plotting
sect.gva.long <- sect.gva %>%
  pivot_longer(cols = starts_with("gva_"),
               names_to = "sector",
               values_to = "GVA") %>%
  mutate(year = as.factor(year))

# Plot density curves of GVA in Sector A by year
ggplot(sect.gva.long %>% filter(sector == "gva_A"), aes(x = GVA, fill = year)) +
  geom_density(alpha = 0.4) +
  xlim(0, 10) +
  theme_minimal() +
  labs(
    title = "Density Plot Share of GVA in Sector A by Year",
    x = "Percent",
    y = "Density"
  )

#### Step 4: Download and read shapefile for map visualization

# Create folder to store shapefiles
dir.create("data/LAMA_SHP", recursive = TRUE, showWarnings = FALSE)

# List of shapefile component URLs
urls <- c(
  "https://zenodo.org/records/10990809/files/additional_nuts_labels.xlsx?download=1",
  "https://zenodo.org/records/10990809/files/shp_nuts.cpg?download=1",
  "https://zenodo.org/records/10990809/files/shp_nuts.dbf?download=1",
  "https://zenodo.org/records/10990809/files/shp_nuts.prj?download=1",
  "https://zenodo.org/records/10990809/files/shp_nuts.qmd?download=1",
  "https://zenodo.org/records/10990809/files/shp_nuts.shp?download=1",
  "https://zenodo.org/records/10990809/files/shp_nuts.shx?download=1"
)

# Download each shapefile component
for (url in urls) {
  file_name <- sub("\\?.*$", "", basename(url))  # Remove query string
  dest_path <- file.path("data/LAMA_SHP", file_name)
  download.file(url, destfile = dest_path, mode = "wb")
}

# Read the shapefile into an sf object
LAMA_NUTS <- read_sf('data/LAMA_SHP/shp_nuts.shp')

#### Step 5: Create a map showing employment in Sector A for 2020

# Join shapefile with employment data for 2020 (Sector A)
map_data <- LAMA_NUTS %>%
  filter(LEVL_CODE == 2) %>%
  left_join(
    sect.emp.long %>%
      filter(sector == "emp_A", year == "2020") %>%
      rename(NUTS_ID = NUTS),
    by = "NUTS_ID"
  )

# Plot map with raw employment shares
ggplot(map_data) +
  geom_sf(aes(fill = employment), color = NA) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey90", name = "Percent") +
  labs(
    title = "Employment Share in Sector A (2020)",
    subtitle = "LAMASUS NUTS2 regions",
    caption = "Data: LAMASUS economic dataset"
  ) +
  coord_sf(xlim = c(2500000, 6500000), ylim = c(1200000, 5500000), expand = FALSE) +
  theme_minimal() +
  theme(legend.position = "right")

# Plot map capped at 10% employment share
ggplot(map_data %>% mutate(employment = ifelse(employment > 10, 10, employment))) +
  geom_sf(aes(fill = employment), color = NA) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey90", name = "Percent") +
  labs(
    title = "Employment Share in Agricultural Sector (2020)",
    subtitle = "LAMASUS NUTS2 regions",
    caption = "Data: LAMASUS economic dataset"
  ) +
  coord_sf(xlim = c(2500000, 6500000), ylim = c(1200000, 5500000), expand = FALSE) +
  theme_minimal() +
  theme(legend.position = "right")

# Save the capped employment map
ggsave(last_plot(), file = "plots/emp_map.png", height = 8, width = 6)

#### Step 6: Create a map showing GVA in Sector A for 2020

# Join shapefile with GVA data for 2020 (Sector A)
map_data2 <- LAMA_NUTS %>%
  filter(LEVL_CODE == 2) %>%
  left_join(
    sect.gva.long %>%
      filter(sector == "gva_A", year == "2020") %>%
      rename(NUTS_ID = NUTS),
    by = "NUTS_ID"
  )

# Plot map with raw GVA shares
ggplot(map_data2) +
  geom_sf(aes(fill = GVA), color = NA) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey90", name = "Percent") +
  labs(
    title = "GVA Share in Sector A (2020)",
    subtitle = "LAMASUS NUTS2 regions",
    caption = "Data: LAMASUS economic dataset"
  ) +
  coord_sf(xlim = c(2500000, 6500000), ylim = c(1200000, 5500000), expand = FALSE) +
  theme_minimal() +
  theme(legend.position = "right")

# Plot map capped at 10% GVA share
ggplot(map_data2 %>% mutate(GVA = ifelse(GVA > 10, 10, GVA))) +
  geom_sf(aes(fill = GVA), color = NA) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey90", name = "Percent") +
  labs(
    title = "GVA Share in Sector A (2020)",
    subtitle = "LAMASUS NUTS2 regions",
    caption = "Data: LAMASUS economic dataset"
  ) +
  coord_sf(xlim = c(2500000, 6500000), ylim = c(1200000, 5500000), expand = FALSE) +
  theme_minimal() +
  theme(legend.position = "right")
