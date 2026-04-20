import 'package:flutter/foundation.dart';
import 'enums.dart';

class ItemDef {
  final String id;
  final String name;
  final String description;
  final ItemClass classification;
  final List<JobType>? usableBy;
  final int requiredMerchantLevel;
  final int baseValue;
  final List<AlchemyElement> baseElements;

  const ItemDef({
    required this.id,
    required this.name,
    required this.description,
    required this.classification,
    required this.baseValue,
    this.usableBy,
    this.requiredMerchantLevel = 0,
    this.baseElements = const [],
  });
}

// Dynamic Instance sitting in an inventory slot
class ItemInstance {
  final String defId;
  final List<AlchemyElement> magicImbued;
  int quantity;

  // Used for dynamically named items (e.g. Iron Nail vs Tin Nail)
  final String? customPrefix;

  ItemInstance({
    required this.defId,
    required this.quantity,
    this.magicImbued = const [],
    this.customPrefix,
  });

  String get displayName {
    final def = GlobalItemRegistry.getDef(defId);
    if (customPrefix != null) {
      return "$customPrefix ${def.name}";
    }
    return def.name;
  }

  // Two items can only stack if their definitions and magical properties are identical
  bool canStackWith(ItemInstance other) {
    if (defId != other.defId) return false;
    if (customPrefix != other.customPrefix) return false;
    if (magicImbued.length != other.magicImbued.length) return false;
    for (int i = 0; i < magicImbued.length; i++) {
      if (magicImbued[i] != other.magicImbued[i]) return false;
    }
    return true;
  }
}

class GlobalItemRegistry {
  static const Map<String, ItemDef> _items = {
    // HERBS
    'basil': ItemDef(
      id: 'basil',
      name: 'Basil',
      description:
          'A distinctly earthy leaf holding natural vitality. Excellent for starter healing drafts.',
      classification: ItemClass.material,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 0,
      baseValue: 50,
      baseElements: [
        AlchemyElement.nature,
        AlchemyElement.earth,
        AlchemyElement.health,
      ],
    ),
    'thyme': ItemDef(
      id: 'thyme',
      name: 'Thyme',
      description:
          'Small sprigs that crackle slightly with static energy. Grants speed.',
      classification: ItemClass.material,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 10,
      baseValue: 60,
      baseElements: [AlchemyElement.haste, AlchemyElement.air],
    ),
    'mint': ItemDef(
      id: 'mint',
      name: 'Mint',
      description:
          'Leaves that remain cold to the touch regardless of weather.',
      classification: ItemClass.material,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 5,
      baseValue: 40,
      baseElements: [AlchemyElement.cooling, AlchemyElement.water],
    ),
    'nettles': ItemDef(
      id: 'nettles',
      name: 'Nettles',
      description: 'Prickly weeds that carry the essence of raw fire.',
      classification: ItemClass.material,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 5,
      baseValue: 40,
      baseElements: [AlchemyElement.fire, AlchemyElement.nature],
    ),

    // ORES & BASES
    'animal_fat': ItemDef(
      id: 'animal_fat',
      name: 'Animal Fat',
      description: 'A thick, greasy substance used to bind herbs into a salve.',
      classification: ItemClass.material,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 0,
      baseValue: 20,
    ),
    'tin_ore': ItemDef(
      id: 'tin_ore',
      name: 'Raw Tin',
      description: 'A soft, pliable metal found near the surface.',
      classification: ItemClass.material,
      usableBy: [JobType.blacksmith_nailsmith, JobType.blacksmith_swordsmith],
      requiredMerchantLevel: 0,
      baseValue: 20,
    ),
    'copper_ore': ItemDef(
      id: 'copper_ore',
      name: 'Raw Copper',
      description: 'An orange-hued metal essential for early tools.',
      classification: ItemClass.material,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 5,
      baseValue: 40,
    ),
    'iron_ore': ItemDef(
      id: 'iron_ore',
      name: 'Raw Iron',
      description: 'A heavy, sturdy rock containing strong metal.',
      classification: ItemClass.material,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 10,
      baseValue: 100,
    ),

    // INGOTS
    'tin_ingot': ItemDef(
      id: 'tin_ingot',
      name: 'Tin Ingot',
      description: 'A purified bar of tin.',
      classification: ItemClass.ingot,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 0,
      baseValue: 50,
    ),
    'iron_ingot': ItemDef(
      id: 'iron_ingot',
      name: 'Iron Ingot',
      description: 'A strong bar of solid iron.',
      classification: ItemClass.ingot,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 10,
      baseValue: 200,
    ),
    'copper_ingot': ItemDef(
      id: 'copper_ingot',
      name: 'Copper Ingot',
      description: 'A conductive bar of copper.',
      classification: ItemClass.ingot,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 5,
      baseValue: 80,
    ),

    // FUELS
    'wood': ItemDef(
      id: 'wood',
      name: 'Log of Wood',
      description: 'Basic timber. Burns fast.',
      classification: ItemClass.material,
      requiredMerchantLevel: 0,
      baseValue: 10,
    ),
    'coal': ItemDef(
      id: 'coal',
      name: 'Lump of Coal',
      description: 'Burns significantly hotter and longer than wood.',
      classification: ItemClass.material,
      requiredMerchantLevel: 10,
      baseValue: 50,
    ),

    // REEVER TOWN RESOURCES
    'lumber': ItemDef(
      id: 'lumber',
      name: 'Lumber',
      description: 'Rough sawn wood planks used in town construction.',
      classification: ItemClass.material,
      usableBy: [JobType.reever],
      requiredMerchantLevel: 0,
      baseValue: 50,
    ),
    'grain': ItemDef(
      id: 'grain',
      name: 'Sack of Grain',
      description: 'Raw wheat harvested from local fields.',
      classification: ItemClass.material,
      usableBy: [JobType.reever],
      requiredMerchantLevel: 0,
      baseValue: 5,
    ),
    'veggies': ItemDef(
      id: 'veggies',
      name: 'Basket of Vegetables',
      description: 'Assorted root vegetables to feed the town.',
      classification: ItemClass.material,
      usableBy: [JobType.reever],
      requiredMerchantLevel: 0,
      baseValue: 8,
    ),
    'meat': ItemDef(
      id: 'meat',
      name: 'Cured Meat',
      description: 'Smoked animal protein to keep the town hardy.',
      classification: ItemClass.material,
      usableBy: [JobType.reever],
      requiredMerchantLevel: 0,
      baseValue: 15,
    ),

    // EQUIPMENT
    'smooth_rock': ItemDef(
      id: 'smooth_rock',
      name: 'Smooth Rock',
      description:
          'A heavy, rounded stone. Very crude, but can grind dry herbs into a rough powder.',
      classification: ItemClass.equipment,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 0,
      baseValue: 5,
    ),
    'mortar_pestle': ItemDef(
      id: 'mortar_pestle',
      name: 'Mortar & Pestle',
      description:
          'A ceramic bowl and grinding tool. Perfect for pulverizing fine powders.',
      classification: ItemClass.equipment,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 5,
      baseValue: 300,
    ),
    'cauldron': ItemDef(
      id: 'cauldron',
      name: 'Cast-Iron Cauldron',
      description:
          'A heavy pot capable of boiling standard drafts without cracking.',
      classification: ItemClass.equipment,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 0,
      baseValue: 500,
    ),
    'alembic': ItemDef(
      id: 'alembic',
      name: 'Copper Alembic',
      description:
          'A precise distillation tool. Essential for high-tier alchemy.',
      classification: ItemClass.equipment,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 20,
      baseValue: 2000,
    ),
    'novice_smelter': ItemDef(
      id: 'novice_smelter',
      name: 'Novice Smelter',
      description: 'A basic furnace used to melt raw ores down into ingots.',
      classification: ItemClass.equipment,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 0,
      baseValue: 1000,
    ),
    'novice_anvil': ItemDef(
      id: 'novice_anvil',
      name: 'Novice Anvil',
      description: 'A sturdy iron block used to forge hot metal against.',
      classification: ItemClass.equipment,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 0,
      baseValue: 800,
    ),
    'novice_hammer': ItemDef(
      id: 'novice_hammer',
      name: 'Novice Hammer',
      description:
          'A heavy metal hammer used to pound blanks into finished shapes.',
      classification: ItemClass.equipment,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 0,
      baseValue: 500,
    ),
    'mold_nail': ItemDef(
      id: 'mold_nail',
      name: 'Nail Mold',
      description:
          'A clay cast used to pour liquid metal into the rough shape of a nail blank.',
      classification: ItemClass.equipment,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 0,
      baseValue: 100,
    ),
    'mold_saw': ItemDef(
      id: 'mold_saw',
      name: 'Saw Mold',
      description:
          'A clay cast used to pour liquid metal into the rough shape of a saw blank.',
      classification: ItemClass.equipment,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 15,
      baseValue: 1000,
    ),

    // CONTAINERS
    'empty_pouch': ItemDef(
      id: 'empty_pouch',
      name: 'Leather Pouch',
      description: 'A tiny drawstring bag used for storing dry powders.',
      classification: ItemClass.container,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 0,
      baseValue: 5,
    ),
    'wooden_tin': ItemDef(
      id: 'wooden_tin',
      name: 'Wooden Tin',
      description:
          'A shallow wooden container with a lid. Ideal for storing thick salves.',
      classification: ItemClass.container,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 0,
      baseValue: 15,
    ),
    'empty_gourd_flask': ItemDef(
      id: 'empty_gourd_flask',
      name: 'Dried Gourd Flask',
      description: 'A hollowed gourd. Cheap, but porous.',
      classification: ItemClass.container,
      usableBy: [JobType.apothecary],
      requiredMerchantLevel: 0,
      baseValue: 20,
    ),

    // BLANKS
    'blank_nail': ItemDef(
      id: 'blank_nail',
      name: 'Nail Blank',
      description:
          'A rough, unsharpened stick of metal. Needs to be forged on an anvil.',
      classification: ItemClass.blank,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 0,
      baseValue: 80,
    ),
    'blank_saw': ItemDef(
      id: 'blank_saw',
      name: 'Saw Blank',
      description:
          'A jagged thick flat bar of metal. Needs to be ground on an anvil.',
      classification: ItemClass.blank,
      usableBy: [JobType.blacksmith_nailsmith],
      requiredMerchantLevel: 15,
      baseValue: 850,
    ),

    // PRODUCTS
    'powder_draft': ItemDef(
      id: 'powder_draft',
      name: 'Apothecary Powder',
      description: 'A finely ground mixture of herbs.',
      classification: ItemClass.potion,
      baseValue: 50,
    ),
    'salve_draft': ItemDef(
      id: 'salve_draft',
      name: 'Apothecary Salve',
      description: 'A thick, spreadable ointment binding herbs together.',
      classification: ItemClass.potion,
      baseValue: 100,
    ),
    'custom_potion': ItemDef(
      id: 'custom_potion',
      name: 'Potion Draft',
      description: 'A liquid swirling with unknown properties.',
      classification: ItemClass.potion,
      baseValue: 250,
    ),
    'metal_nail': ItemDef(
      id: 'metal_nail',
      name: 'Nails',
      description: 'Standard fasteners for holding wood together.',
      classification: ItemClass.product,
      baseValue: 150,
    ),

    // CONSUMABLES
    'bread': ItemDef(
      id: 'bread',
      name: 'Loaf of Bread',
      description: 'A warm, crusty loaf. Consume to restore 20% Hunger.',
      classification: ItemClass.consumable,
      baseValue: 10,
    ),
  };

  static ItemDef getDef(String id) {
    return _items[id] ??
        ItemDef(
          id: 'unknown',
          name: 'Unknown Item',
          description: 'Error missing def.',
          classification: ItemClass.other,
          baseValue: 0,
        );
  }

  static List<ItemDef> getAllDefs() => _items.values.toList();
}
