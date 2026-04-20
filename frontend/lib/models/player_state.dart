import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'enums.dart';
import 'item_model.dart';
import 'alchemy.dart'; // We still use AlchemyEngine for mixing logic
import 'save_manager.dart'; // We will create this next

class CraftingTask {
  final List<String> equipmentUsed;
  final String? containerUsed; // Nullable for blacksmith
  final List<String> materials;
  final String yieldDefId; // What this outputs
  final String? customPrefix; // E.g., 'Iron'
  final Map<AlchemyElement, int> resultingElements;
  int remainingTicks;
  final int skillLevelSnapshot;
  final JobType ownerPersona;

  CraftingTask({
    required this.equipmentUsed,
    required this.containerUsed,
    required this.materials,
    required this.yieldDefId,
    this.customPrefix,
    required this.resultingElements,
    required this.remainingTicks,
    required this.skillLevelSnapshot,
    required this.ownerPersona,
  });
}

class PlayerState extends ChangeNotifier {
  JobType _currentJob = JobType.apothecary;
  JobType get currentJob => _currentJob;

  bool isShopOpen = false;

  ThemeMode _currentTheme = ThemeMode.dark;
  ThemeMode get currentTheme => _currentTheme;
  void toggleTheme() {
    _currentTheme = _currentTheme == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  // Hunger Mechanism
  int _hunger = 100; // 100 is full, 0 is starving
  int _maxHunger = 100;
  int get hunger => _hunger;
  int get maxHunger => _maxHunger;

  Set<JobType> _unlockedJobs = {
    JobType.apothecary,
    JobType.blacksmith_nailsmith,
    JobType.reever,
  };
  bool isJobUnlocked(JobType job) => _unlockedJobs.contains(job);

  // Wallets
  Map<JobType, int> _wallets = {
    JobType.apothecary: 1500,
    JobType.blacksmith_nailsmith: 200,
    JobType.reever: 5000,
  };
  Map<JobType, int> get wallets => Map.unmodifiable(_wallets);

  // Town Management / Reever State
  int townMorale = 50;
  int taxCountdown = 60; // Every 60 ticks (seconds) process taxes
  Map<String, int> constructedBuildings = {};
  Map<String, int> hiredWorkers = {};
  int _tickCounter = 0; // Tracks game time for autosaving

  // True Object-Oriented Inventory
  List<ItemInstance> _marketInventory = [];
  Map<JobType, List<ItemInstance>> _inventories = {};

  Map<JobType, List<ItemInstance>> get inventories => _inventories;
  List<ItemInstance> get globalMarket => _marketInventory;

  static const List<String> infiniteItems = [
    'basil',
    'tin_ore',
    'wood',
    'bread',
    'grain',
    'veggies',
    'meat',
    'lumber',
  ];

  PlayerState() {
    _seedIdenticalMarketItems('iron_ore', 100);
    _seedIdenticalMarketItems('copper_ore', 100);
    _seedIdenticalMarketItems('coal', 200);
    _seedIdenticalMarketItems('thyme', 50);
    _seedIdenticalMarketItems('mint', 50);
    _seedIdenticalMarketItems('nettles', 50);
    _seedIdenticalMarketItems('cauldron', 5);
    _seedIdenticalMarketItems('empty_gourd_flask', 100);
    _seedIdenticalMarketItems('novice_smelter', 2);
    _seedIdenticalMarketItems('novice_hammer', 5);
    _seedIdenticalMarketItems('novice_anvil', 2);
    _seedIdenticalMarketItems('mold_nail', 5);
    _seedIdenticalMarketItems('smooth_rock', 5);
    _seedIdenticalMarketItems('mortar_pestle', 2);
    _seedIdenticalMarketItems('wooden_tin', 50);
    _seedIdenticalMarketItems('empty_pouch', 100);
    _seedIdenticalMarketItems('animal_fat', 100);

    // Seed player
    addInventoryToPersona(
      JobType.apothecary,
      ItemInstance(defId: 'basil', quantity: 5),
    );
    addInventoryToPersona(
      JobType.apothecary,
      ItemInstance(defId: 'cauldron', quantity: 1),
    );
    addInventoryToPersona(
      JobType.apothecary,
      ItemInstance(defId: 'empty_gourd_flask', quantity: 5),
    );
    addInventoryToPersona(
      JobType.apothecary,
      ItemInstance(defId: 'smooth_rock', quantity: 1),
    );
    addInventoryToPersona(
      JobType.apothecary,
      ItemInstance(defId: 'empty_pouch', quantity: 10),
    );

    addInventoryToPersona(
      JobType.blacksmith_nailsmith,
      ItemInstance(defId: 'iron_ore', quantity: 10),
    );
    addInventoryToPersona(
      JobType.blacksmith_nailsmith,
      ItemInstance(defId: 'tin_ore', quantity: 10),
    );
    addInventoryToPersona(
      JobType.blacksmith_nailsmith,
      ItemInstance(defId: 'coal', quantity: 10),
    );
    addInventoryToPersona(
      JobType.blacksmith_nailsmith,
      ItemInstance(defId: 'novice_hammer', quantity: 1),
    );
    addInventoryToPersona(
      JobType.blacksmith_nailsmith,
      ItemInstance(defId: 'novice_smelter', quantity: 1),
    );
    addInventoryToPersona(
      JobType.blacksmith_nailsmith,
      ItemInstance(defId: 'novice_anvil', quantity: 1),
    );
    addInventoryToPersona(
      JobType.blacksmith_nailsmith,
      ItemInstance(defId: 'mold_nail', quantity: 1),
    );

    // Initially Load game from persistence if exists, we will handle async in main usually, but simple load here.
    SaveManager.loadGame(this);
  }

  void overwriteState(Map<String, dynamic> data) {
    // Called by SaveManager to inject the loaded graph
    if (data['themeMode'] != null) {
      _currentTheme = ThemeMode.values[data['themeMode']];
    }
    _hunger = data['hunger'] ?? 100;
    townMorale = data['townMorale'] ?? 50;

    // Wallets
    if (data['wallets'] != null) {
      (data['wallets'] as Map<String, dynamic>).forEach((k, v) {
        JobType job = JobType.values.firstWhere((e) => e.toString() == k);
        _wallets[job] = v;
      });
    }

    // Buildings
    if (data['constructedBuildings'] != null) {
      constructedBuildings = Map<String, int>.from(
        data['constructedBuildings'],
      );
    }

    // Workers
    if (data['hiredWorkers'] != null) {
      hiredWorkers = Map<String, int>.from(data['hiredWorkers']);
    }

    // Note: We bypass deep inventory population for simplicity in prototype, relies on seed.
    notifyListeners();
  }

  void _seedIdenticalMarketItems(String defId, int qty) {
    _marketInventory.add(ItemInstance(defId: defId, quantity: qty));
  }

  Map<JobType, int> _skills = {
    JobType.apothecary: 1,
    JobType.blacksmith_nailsmith: 1,
    JobType.merchant: 1, // Determines what the merchant sells
  };

  List<CraftingTask> _activeTasks = [];
  List<CraftingTask> get activeTasks => List.unmodifiable(_activeTasks);

  String formatCurrency(int tin) {
    if (tin == 0) return "0C";
    int plat = tin ~/ 1000000000;
    int rem = tin % 1000000000;
    int gold = rem ~/ 1000000;
    rem = rem % 1000000;
    int silver = rem ~/ 1000;
    int copper = rem % 1000;

    String out = "";
    if (plat > 0) out += "${plat}P ";
    if (gold > 0) out += "${gold}G ";
    if (silver > 0) out += "${silver}S ";
    out += "${copper + rem}C";
    return out.trim();
  }

  String get formattedActiveWallet {
    return formatCurrency(_wallets[_currentJob] ?? 0);
  }

  int getSkillLevel(JobType job) => _skills[job] ?? 1;

  // --- ITEM ENGINE ---

  List<ItemInstance> get activeInventory => _inventories[_currentJob] ?? [];
  List<ItemInstance> get marketInventory => _marketInventory;

  int getActiveInventoryItemCount(String defId) {
    return activeInventory
        .where((i) => i.defId == defId)
        .fold<int>(0, (sum, i) => sum + i.quantity);
  }

  int getMarketInventoryItemCount(String defId) {
    if (infiniteItems.contains(defId)) return 999; // Represents infinite
    return _marketInventory
        .where((i) => i.defId == defId)
        .fold<int>(0, (sum, i) => sum + i.quantity);
  }

  // Gets the ACTUAL instance we have of something, useful for tracking dynamic stuff. If we have stacks, takes first.
  ItemInstance? getFirstActiveInstance(String defId) {
    final list = activeInventory.where((i) => i.defId == defId).toList();
    if (list.isEmpty) return null;
    return list.first;
  }

  void toggleShop(bool isOpen) {
    isShopOpen = isOpen;
    notifyListeners();
  }

  void switchJob(JobType newJob) {
    if (isJobUnlocked(newJob)) {
      _currentJob = newJob;
      isShopOpen = false;
      notifyListeners();
    }
  }

  void addInventoryToPersona(JobType persona, ItemInstance incomingItem) {
    _inventories[persona] ??= [];
    var inv = _inventories[persona]!;

    for (var existing in inv) {
      if (existing.canStackWith(incomingItem)) {
        existing.quantity += incomingItem.quantity;
        notifyListeners();
        return;
      }
    }

    inv.add(incomingItem);
    notifyListeners();
  }

  bool consumeInventoryFromPersona(JobType persona, String defId, int amount) {
    int current =
        _inventories[persona]
            ?.where((i) => i.defId == defId)
            .fold<int>(0, (sum, i) => sum + i.quantity) ??
        0;
    if (current < amount) return false;

    int remainingToConsume = amount;
    var inv = _inventories[persona]!;

    for (int i = inv.length - 1; i >= 0; i--) {
      var instance = inv[i];
      if (instance.defId == defId) {
        if (instance.quantity <= remainingToConsume) {
          remainingToConsume -= instance.quantity;
          inv.removeAt(i);
        } else {
          instance.quantity -= remainingToConsume;
          remainingToConsume = 0;
        }

        if (remainingToConsume == 0) break;
      }
    }

    notifyListeners();
    return true;
  }

  bool consumeFood(ItemInstance foodInstance) {
    final def = GlobalItemRegistry.getDef(foodInstance.defId);
    if (def.classification != ItemClass.consumable) return false;

    // Remove 1 from inventory
    consumeInventoryFromPersona(_currentJob, foodInstance.defId, 1);

    // Hardcoded bread restores 20%
    _hunger = min(_maxHunger, _hunger + 20);
    notifyListeners();
    return true;
  }

  bool buyFromMarket(String defId, int cost) {
    if (getMarketInventoryItemCount(defId) >= 1) {
      int wallet = _wallets[_currentJob] ?? 0;
      if (wallet >= cost) {
        _wallets[_currentJob] = wallet - cost;

        // Remove 1 from market (if not infinite)
        if (!infiniteItems.contains(defId)) {
          for (int i = 0; i < _marketInventory.length; i++) {
            if (_marketInventory[i].defId == defId) {
              if (_marketInventory[i].quantity == 1) {
                _marketInventory.removeAt(i);
              } else {
                _marketInventory[i].quantity -= 1;
              }
              break;
            }
          }
        }

        // Add exact replica to player
        addInventoryToPersona(
          _currentJob,
          ItemInstance(defId: defId, quantity: 1),
        );
        return true;
      }
    }
    return false;
  }

  bool sellToMarket(ItemInstance instanceToSell, int price) {
    var inv = _inventories[_currentJob];
    if (inv == null) return false;

    for (int i = inv.length - 1; i >= 0; i--) {
      if (inv[i] == instanceToSell) {
        if (inv[i].quantity == 1) {
          inv.removeAt(i);
        } else {
          inv[i].quantity -= 1;
        }

        _wallets[_currentJob] = (_wallets[_currentJob] ?? 0) + price;

        var clone = ItemInstance(
          defId: instanceToSell.defId,
          quantity: 1,
          magicImbued: instanceToSell.magicImbued,
          customPrefix: instanceToSell.customPrefix,
        );

        if (!infiniteItems.contains(clone.defId)) {
          bool stacked = false;
          for (var m in _marketInventory) {
            if (m.canStackWith(clone)) {
              m.quantity += 1;
              stacked = true;
              break;
            }
          }
          if (!stacked) _marketInventory.add(clone);
        }

        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // --- Town Macros ---

  void buildStructure(String buildingId, int cost, Map<String, int> materials) {
    int wallet = _wallets[JobType.reever] ?? 0;
    if (wallet < cost) return;

    for (var entry in materials.entries) {
      if (getActiveInventoryItemCount(entry.key) < entry.value) return;
    }

    _wallets[JobType.reever] = wallet - cost;
    for (var entry in materials.entries) {
      consumeInventoryFromPersona(JobType.reever, entry.key, entry.value);
    }

    constructedBuildings[buildingId] =
        (constructedBuildings[buildingId] ?? 0) + 1;
    notifyListeners();
  }

  // --- Crafting Validations ---

  bool startCraftingAttempt({
    required List<String> equipment,
    String? container,
    required List<String> materials,
    required String outputDefId,
    String? outputCustomPrefix,
  }) {
    if (_hunger <= 0) return false; // Starving!

    for (var eq in equipment) {
      int equipmentOwned = getActiveInventoryItemCount(eq);
      int equipmentInUse = _activeTasks
          .where(
            (t) =>
                t.equipmentUsed.contains(eq) && t.ownerPersona == _currentJob,
          )
          .length;
      if (equipmentOwned <= equipmentInUse) return false;
    }

    if (container != null && getActiveInventoryItemCount(container) < 1)
      return false;

    Map<String, int> requiredMaterials = {};
    for (var mat in materials) {
      if (mat.isNotEmpty)
        requiredMaterials[mat] = (requiredMaterials[mat] ?? 0) + 1;
    }
    for (var entry in requiredMaterials.entries) {
      if (getActiveInventoryItemCount(entry.key) < entry.value) return false;
    }

    // Consume Items
    if (container != null)
      consumeInventoryFromPersona(_currentJob, container, 1);
    for (var entry in requiredMaterials.entries) {
      consumeInventoryFromPersona(_currentJob, entry.key, entry.value);
    }

    // Active Hunger Drain: performing a task costs 1 hunger point
    _hunger = max(0, _hunger - 1);

    var resultingElements = AlchemyEngine.mixHerbs(materials);

    _activeTasks.add(
      CraftingTask(
        equipmentUsed: equipment,
        containerUsed: container,
        materials: materials,
        resultingElements: resultingElements,
        remainingTicks: 3,
        yieldDefId: outputDefId,
        customPrefix: outputCustomPrefix,
        skillLevelSnapshot: getSkillLevel(_currentJob),
        ownerPersona: _currentJob,
      ),
    );

    notifyListeners();
    return true;
  }

  void processTick() {
    bool hasChanges = false;
    List<CraftingTask> completedTasks = [];

    // TICK TIMER FOR AUTO SAVE
    _tickCounter += 1;
    if (_tickCounter >= 600) {
      // ~10 minutes
      SaveManager.saveGame(this);
      _tickCounter = 0;
    }

    // PASSIVE HUNGER DRAIN (very slow)
    if (_tickCounter % 30 == 0) {
      // Roughly every 30 seconds lose 1 hunger point
      _hunger = max(0, _hunger - 1);
      hasChanges = true;
    }

    // TOWN TAX COLLECTION
    taxCountdown -= 1;
    if (taxCountdown <= 0) {
      taxCountdown = 60; // Reset

      // Compute taxes: 10c per house
      int houses =
          (constructedBuildings['small_house'] ?? 0) +
          ((constructedBuildings['large_house'] ?? 0) * 3);
      int collected = houses * 10;

      if (collected > 0) {
        _wallets[JobType.reever] = (_wallets[JobType.reever] ?? 0) + collected;
      }

      // Update Morale based on food variety vs houses
      int foodTypes = 0;
      for (String food in ['grain', 'veggies', 'meat', 'bread']) {
        if (getActiveInventoryItemCount(food) > 0) foodTypes++;
      }
      if (foodTypes >= 3)
        townMorale += 2;
      else if (foodTypes == 0 && houses > 0)
        townMorale -= 5;

      townMorale = townMorale.clamp(0, 100);
      hasChanges = true;
    }

    for (var task in _activeTasks) {
      task.remainingTicks -= 1;
      hasChanges = true;
      if (task.remainingTicks <= 0) {
        completedTasks.add(task);
      }
    }

    final rand = Random();
    for (var task in completedTasks) {
      _activeTasks.remove(task);

      double failChance = 0.05;
      if (rand.nextDouble() > failChance) {
        List<AlchemyElement> imbue = [];
        task.resultingElements.forEach((key, value) {
          if (value > 0) imbue.add(key);
        });

        addInventoryToPersona(
          task.ownerPersona,
          ItemInstance(
            defId: task.yieldDefId,
            quantity: 1,
            customPrefix: task.customPrefix,
            magicImbued: imbue,
          ),
        );

        _skills[task.ownerPersona] = (_skills[task.ownerPersona] ?? 1) + 1;
      }
    }
    if (hasChanges) notifyListeners();
  }
}
