"""
Blinkit Grocery Sales Analysis
Python / Pandas / Matplotlib
Author: Jyotheeswaran G

Place the Excel file in the same folder and update FILE_PATH if needed.
The script automatically normalizes common Blinkit column names.
"""

from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

FILE_PATH = Path("BlinkIT Grocery Data.xlsx")
OUTPUT_DIR = Path("blinkit_python_outputs")
OUTPUT_DIR.mkdir(exist_ok=True)

# ------------------------------------------------------------
# 1. LOAD DATA
# ------------------------------------------------------------
df = pd.read_excel(FILE_PATH)
print("Shape:", df.shape)
print("\nColumns:")
print(df.columns.tolist())

# ------------------------------------------------------------
# 2. STANDARDIZE COLUMN NAMES
# ------------------------------------------------------------
def normalize_col(name):
    return (
        str(name).strip().lower()
        .replace(" ", "_")
        .replace("-", "_")
        .replace("/", "_")
        .replace("(", "")
        .replace(")", "")
        .replace(".", "")
    )

df.columns = [normalize_col(c) for c in df.columns]

# Common aliases in Blinkit datasets
aliases = {
    "item_identifier": ["item_identifier", "item_id", "product_id"],
    "item_weight": ["item_weight", "weight"],
    "item_fat_content": ["item_fat_content", "fat_content", "fat"],
    "item_visibility": ["item_visibility", "visibility"],
    "item_type": ["item_type", "product_type", "category"],
    "item_mrp": ["item_mrp", "mrp", "price"],
    "outlet_identifier": ["outlet_identifier", "outlet_id", "store_id"],
    "outlet_establishment_year": ["outlet_establishment_year", "establishment_year", "outlet_year"],
    "outlet_size": ["outlet_size", "store_size"],
    "outlet_location_type": ["outlet_location_type", "location_type", "location_tier"],
    "outlet_type": ["outlet_type", "store_type"],
    "sales": ["sales", "revenue"],
    "rating": ["rating", "ratings"],
}

rename_map = {}
for standard, candidates in aliases.items():
    for candidate in candidates:
        if candidate in df.columns:
            rename_map[candidate] = standard
            break

df = df.rename(columns=rename_map)

required = ["item_type", "sales"]
missing_required = [c for c in required if c not in df.columns]
if missing_required:
    raise ValueError(
        f"Missing required columns: {missing_required}. "
        f"Available columns: {df.columns.tolist()}"
    )

# ------------------------------------------------------------
# 3. DATA CLEANING
# ------------------------------------------------------------
if "item_fat_content" in df.columns:
    df["item_fat_content"] = (
        df["item_fat_content"]
        .astype(str)
        .str.strip()
        .replace({
            "LF": "Low Fat",
            "lf": "Low Fat",
            "low fat": "Low Fat",
            "reg": "Regular",
            "REG": "Regular",
            "regular": "Regular",
        })
    )

numeric_cols = [
    "item_weight", "item_visibility", "item_mrp",
    "outlet_establishment_year", "sales", "rating"
]

for col in numeric_cols:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce")

# Fill item weight with median by item type when possible
if "item_weight" in df.columns:
    if "item_type" in df.columns:
        df["item_weight"] = df.groupby("item_type")["item_weight"].transform(
            lambda s: s.fillna(s.median())
        )
    df["item_weight"] = df["item_weight"].fillna(df["item_weight"].median())

# Basic duplicate check
duplicate_count = int(df.duplicated().sum())
print("\nDuplicate rows:", duplicate_count)

# Remove exact duplicate rows
df = df.drop_duplicates().copy()

# ------------------------------------------------------------
# 4. DATA QUALITY REPORT
# ------------------------------------------------------------
quality = pd.DataFrame({
    "column": df.columns,
    "data_type": [str(df[c].dtype) for c in df.columns],
    "missing_values": [int(df[c].isna().sum()) for c in df.columns],
    "unique_values": [int(df[c].nunique(dropna=True)) for c in df.columns],
})
quality.to_csv(OUTPUT_DIR / "data_quality_report.csv", index=False)

print("\nData quality report:")
print(quality)

# ------------------------------------------------------------
# 5. KPI ANALYSIS
# ------------------------------------------------------------
total_sales = df["sales"].sum()
average_sales = df["sales"].mean()
total_records = len(df)
distinct_items = df["item_identifier"].nunique() if "item_identifier" in df.columns else np.nan
distinct_outlets = df["outlet_identifier"].nunique() if "outlet_identifier" in df.columns else np.nan
average_rating = df["rating"].mean() if "rating" in df.columns else np.nan

kpis = pd.DataFrame({
    "KPI": [
        "Total Sales", "Average Sales", "Total Records",
        "Distinct Items", "Distinct Outlets", "Average Rating"
    ],
    "Value": [
        total_sales, average_sales, total_records,
        distinct_items, distinct_outlets, average_rating
    ]
})
kpis.to_csv(OUTPUT_DIR / "kpis.csv", index=False)

print("\nKPIs")
print(kpis)

# ------------------------------------------------------------
# 6. ITEM TYPE ANALYSIS
# ------------------------------------------------------------
category_sales = (
    df.groupby("item_type", as_index=False)
      .agg(
          revenue=("sales", "sum"),
          average_sales=("sales", "mean"),
          records=("sales", "size")
      )
      .sort_values("revenue", ascending=False)
)
category_sales.to_csv(OUTPUT_DIR / "sales_by_item_type.csv", index=False)

print("\nTop item categories:")
print(category_sales.head(10))

# ------------------------------------------------------------
# 7. OUTLET ANALYSIS
# ------------------------------------------------------------
if "outlet_type" in df.columns:
    outlet_type_sales = (
        df.groupby("outlet_type", as_index=False)
          .agg(revenue=("sales", "sum"), average_sales=("sales", "mean"))
          .sort_values("revenue", ascending=False)
    )
    outlet_type_sales.to_csv(OUTPUT_DIR / "sales_by_outlet_type.csv", index=False)
    print("\nSales by outlet type:")
    print(outlet_type_sales)

if "outlet_location_type" in df.columns:
    location_sales = (
        df.groupby("outlet_location_type", as_index=False)
          .agg(revenue=("sales", "sum"), average_sales=("sales", "mean"))
          .sort_values("revenue", ascending=False)
    )
    location_sales.to_csv(OUTPUT_DIR / "sales_by_location_type.csv", index=False)

if "outlet_size" in df.columns:
    size_sales = (
        df.groupby("outlet_size", as_index=False)
          .agg(revenue=("sales", "sum"), average_sales=("sales", "mean"))
          .sort_values("revenue", ascending=False)
    )
    size_sales.to_csv(OUTPUT_DIR / "sales_by_outlet_size.csv", index=False)

# ------------------------------------------------------------
# 8. FAT CONTENT ANALYSIS
# ------------------------------------------------------------
if "item_fat_content" in df.columns:
    fat_sales = (
        df.groupby("item_fat_content", as_index=False)
          .agg(revenue=("sales", "sum"), average_sales=("sales", "mean"))
          .sort_values("revenue", ascending=False)
    )
    fat_sales.to_csv(OUTPUT_DIR / "sales_by_fat_content.csv", index=False)

# ------------------------------------------------------------
# 9. RATING ANALYSIS
# ------------------------------------------------------------
if "rating" in df.columns:
    rating_analysis = (
        df.groupby("item_type", as_index=False)
          .agg(
              average_rating=("rating", "mean"),
              revenue=("sales", "sum")
          )
          .sort_values("average_rating", ascending=False)
    )
    rating_analysis.to_csv(OUTPUT_DIR / "rating_by_item_type.csv", index=False)

# ------------------------------------------------------------
# 10. TOP ITEMS
# ------------------------------------------------------------
if "item_identifier" in df.columns:
    top_items = (
        df.sort_values("sales", ascending=False)
          .loc[:, [c for c in [
              "item_identifier", "item_type", "item_fat_content",
              "item_mrp", "sales", "rating"
          ] if c in df.columns]]
          .head(20)
    )
    top_items.to_csv(OUTPUT_DIR / "top_20_items.csv", index=False)

# ------------------------------------------------------------
# 11. VISUALIZATIONS
# ------------------------------------------------------------
plt.figure(figsize=(10, 6))
top_categories = category_sales.head(10).sort_values("revenue")
plt.barh(top_categories["item_type"], top_categories["revenue"])
plt.title("Top 10 Item Categories by Sales")
plt.xlabel("Sales")
plt.ylabel("Item Type")
plt.tight_layout()
plt.savefig(OUTPUT_DIR / "top_10_item_categories.png", dpi=200)
plt.close()

if "outlet_type" in df.columns:
    plt.figure(figsize=(9, 5))
    temp = outlet_type_sales.sort_values("revenue")
    plt.barh(temp["outlet_type"], temp["revenue"])
    plt.title("Sales by Outlet Type")
    plt.xlabel("Sales")
    plt.ylabel("Outlet Type")
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / "sales_by_outlet_type.png", dpi=200)
    plt.close()

if "item_fat_content" in df.columns:
    plt.figure(figsize=(7, 5))
    temp = fat_sales.sort_values("revenue")
    plt.bar(temp["item_fat_content"], temp["revenue"])
    plt.title("Sales by Fat Content")
    plt.xlabel("Fat Content")
    plt.ylabel("Sales")
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / "sales_by_fat_content.png", dpi=200)
    plt.close()

# ------------------------------------------------------------
# 12. EXPORT CLEANED DATA
# ------------------------------------------------------------
df.to_csv(OUTPUT_DIR / "blinkit_cleaned_data.csv", index=False)

# ------------------------------------------------------------
# 13. CONSOLE SUMMARY
# ------------------------------------------------------------
print("\n" + "=" * 60)
print("BLINKIT GROCERY SALES ANALYSIS - FINAL SUMMARY")
print("=" * 60)
print(f"Total records       : {total_records:,}")
print(f"Total sales         : {total_sales:,.2f}")
print(f"Average sales       : {average_sales:,.2f}")
print(f"Average rating      : {average_rating:.2f}" if not pd.isna(average_rating) else "Average rating      : N/A")
print(f"Distinct items      : {distinct_items:,.0f}" if not pd.isna(distinct_items) else "Distinct items      : N/A")
print(f"Distinct outlets    : {distinct_outlets:,.0f}" if not pd.isna(distinct_outlets) else "Distinct outlets    : N/A")
print("=" * 60)
print(f"Outputs saved to: {OUTPUT_DIR.resolve()}")