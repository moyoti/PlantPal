package com.plantpal.model

data class DecorationItem(
    val id: String,
    val name: String,
    val category: DecorationCategory,
    val assetName: String,
    val cost: Int,
    val isUnlockedByDefault: Boolean
) {
    companion object {
        val allItems = listOf(
            DecorationItem("pot_default", "陶土盆", DecorationCategory.POT, "pot_default", 0, true),
            DecorationItem("pot_ceramic", "陶瓷盆", DecorationCategory.POT, "pot_ceramic", 10, false),
            DecorationItem("pot_wooden", "木桶盆", DecorationCategory.POT, "pot_wooden", 15, false),
            DecorationItem("pot_golden", "金盆", DecorationCategory.POT, "pot_golden", 50, false),
            DecorationItem("pot_crystal", "水晶盆", DecorationCategory.POT, "pot_crystal", 80, false),
            DecorationItem("bg_garden", "花园", DecorationCategory.BACKGROUND, "bg_garden", 0, true),
            DecorationItem("bg_forest", "森林", DecorationCategory.BACKGROUND, "bg_forest", 20, false),
            DecorationItem("bg_beach", "海滩", DecorationCategory.BACKGROUND, "bg_beach", 20, false),
            DecorationItem("bg_night", "星空", DecorationCategory.BACKGROUND, "bg_night", 30, false),
            DecorationItem("bg_rainbow", "彩虹", DecorationCategory.BACKGROUND, "bg_rainbow", 50, false),
            DecorationItem("outfit_default", "默认", DecorationCategory.OUTFIT, "outfit_default", 0, true),
            DecorationItem("outfit_crown", "小皇冠", DecorationCategory.OUTFIT, "outfit_crown", 30, false),
            DecorationItem("outfit_scarf", "围巾", DecorationCategory.OUTFIT, "outfit_scarf", 15, false),
            DecorationItem("outfit_glasses", "眼镜", DecorationCategory.OUTFIT, "outfit_glasses", 20, false),
            DecorationItem("outfit_wings", "翅膀", DecorationCategory.OUTFIT, "outfit_wings", 60, false),
            DecorationItem("outfit_party", "派对帽", DecorationCategory.OUTFIT, "outfit_party", 25, false)
        )

        fun pots() = allItems.filter { it.category == DecorationCategory.POT }
        fun backgrounds() = allItems.filter { it.category == DecorationCategory.BACKGROUND }
        fun outfits() = allItems.filter { it.category == DecorationCategory.OUTFIT }
    }
}

enum class DecorationCategory(val displayName: String, val icon: String) {
    POT("花盆", "🪴"),
    BACKGROUND("背景", "🏞️"),
    OUTFIT("配饰", "🎩")
}
