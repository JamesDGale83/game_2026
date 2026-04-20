import 'enums.dart';

class HerbDef {
  final String id;
  final String name;
  final List<AlchemyElement> properties;
  final int baseValueTin;

  const HerbDef(this.id, this.name, this.properties, this.baseValueTin);
}

const Map<String, HerbDef> herbDatabase = {
  'basil': HerbDef('basil', 'Basil', [
    AlchemyElement.nature,
    AlchemyElement.earth,
    AlchemyElement.health,
  ], 500),
  'thyme': HerbDef('thyme', 'Thyme', [
    AlchemyElement.haste,
    AlchemyElement.air,
  ], 600),
  'parsley': HerbDef('parsley', 'Parsley', [AlchemyElement.health], 300),
  'wolfsbane': HerbDef('wolfsbane', 'Wolfsbane', [
    AlchemyElement.poison,
    AlchemyElement.earth,
  ], 1500),
  'dandelion': HerbDef('dandelion', 'Dandelion', [
    AlchemyElement.nature,
    AlchemyElement.air,
  ], 200),
  'mint': HerbDef('mint', 'Mint', [
    AlchemyElement.cooling,
    AlchemyElement.water,
  ], 400),
  'nettles': HerbDef('nettles', 'Nettles', [
    AlchemyElement.fire,
    AlchemyElement.nature,
  ], 400),
};

const Map<String, int> equipmentTiers = {'cauldron': 1, 'alembic': 2};

const Map<String, int> containerQualities = {
  'empty_gourd_flask': 1,
  'empty_skin_flask': 2,
  'empty_glass_flask': 3,
};

// Opposing elements that cancel each other out
const Map<AlchemyElement, AlchemyElement> opposingElements = {
  AlchemyElement.fire: AlchemyElement.water,
  AlchemyElement.water: AlchemyElement.fire,
  AlchemyElement.cooling: AlchemyElement.fire,
  AlchemyElement.health: AlchemyElement.poison,
  AlchemyElement.poison: AlchemyElement.health,
};

class AlchemyEngine {
  static Map<AlchemyElement, int> mixHerbs(List<String> herbIds) {
    Map<AlchemyElement, int> elementCounts = {};

    // Tally up all elements
    for (var id in herbIds) {
      if (herbDatabase.containsKey(id)) {
        for (var element in herbDatabase[id]!.properties) {
          elementCounts[element] = (elementCounts[element] ?? 0) + 1;
        }
      }
    }

    // Cancel opposing elements
    Map<AlchemyElement, int> finalCounts = {};
    elementCounts.forEach((element, count) {
      AlchemyElement? opposite = opposingElements[element];
      if (opposite != null && elementCounts.containsKey(opposite)) {
        int oppositeCount = elementCounts[opposite]!;
        if (count > oppositeCount) {
          finalCounts[element] = count - oppositeCount;
        }
        // If they are equal, they both cancel completely, so we add neither.
      } else {
        finalCounts[element] = count;
      }
    });

    return finalCounts;
  }

  // Returns true if craft is successful, false if it failed outright due to lack of skill
  static bool rollSuccess(int skillLevel, int equipmentTier) {
    // If using tier 2 equipment (Alembic) but skill is low, high chance to fail
    double baseFailChance = 0.05; // 5% baseline fail

    // e.g. using Tier 2 equipment requires at least skill level 10 to be proficient
    int skillRequirement = equipmentTier * 10;

    if (skillLevel < skillRequirement) {
      // increase fail chance dramatically
      int deficit = skillRequirement - skillLevel;
      baseFailChance +=
          (deficit * 0.05); // 5% extra fail chance per missing skill level
    }

    return (baseFailChance < 1.0)
        ? true
        : false; // Placeholder random roll can be added here
  }
}
