import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player_state.dart';
import '../../models/item_model.dart';
import '../../models/enums.dart';

class BlacksmithPanel extends StatefulWidget {
  const BlacksmithPanel({Key? key}) : super(key: key);

  @override
  State<BlacksmithPanel> createState() => _BlacksmithPanelState();
}

class _BlacksmithPanelState extends State<BlacksmithPanel> {
  // Smelting
  String _smlEq = 'novice_smelter';
  String _smlFuel = 'coal';
  String _smlOre = 'iron_ore';

  // Molding
  String? _mldEq; // Molds
  String _mldFuel = 'coal';
  String? _mldIngot;

  // Forging
  String _frgAnvil = 'novice_anvil';
  String _frgHammer = 'novice_hammer';
  String? _frgBlank;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? Colors.black.withOpacity(0.85) : Colors.amber[50]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.white70 : Colors.black54;
    Color cardColor = isDark ? Colors.black : Colors.white;
    Color dropdownColor = isDark ? Colors.black : Colors.grey[100]!;
    Color tabUnselected = isDark ? Colors.white54 : Colors.black45;

    return Consumer<PlayerState>(
      builder: (context, state, child) {
        final activeTasks = state.activeTasks.where(
          (t) => t.ownerPersona == state.currentJob,
        );

        // Compute available dynamic items
        List<String> ownedMolds = state.activeInventory
            .map((inst) => GlobalItemRegistry.getDef(inst.defId))
            .where(
              (def) =>
                  def.classification == ItemClass.equipment &&
                  def.id.startsWith('mold_') &&
                  (def.usableBy?.contains(state.currentJob) ?? false),
            )
            .map((def) => def.id)
            .toSet()
            .toList();

        List<String> ownedIngots = state.activeInventory
            .map((inst) => GlobalItemRegistry.getDef(inst.defId))
            .where((def) => def.classification == ItemClass.ingot)
            .map((def) => def.id)
            .toSet()
            .toList();

        List<String> ownedBlanks = state.activeInventory
            .map((inst) => GlobalItemRegistry.getDef(inst.defId))
            .where((def) => def.classification == ItemClass.blank)
            .map((def) => def.id)
            .toSet()
            .toList();

        // Defaults safely
        if (_mldEq == null && ownedMolds.isNotEmpty) _mldEq = ownedMolds.first;
        if (_mldIngot == null && ownedIngots.isNotEmpty)
          _mldIngot = ownedIngots.first;
        if (_frgBlank == null && ownedBlanks.isNotEmpty)
          _frgBlank = ownedBlanks.first;

        final bool _isNailsmith =
            state.currentJob == JobType.blacksmith_nailsmith;

        return DefaultTabController(
          length: 3,
          child: Container(
            constraints: const BoxConstraints(minHeight: 750),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: bgColor,
              image: _isNailsmith && isDark
                  ? const DecorationImage(
                      image: AssetImage(
                        'assets/images/background/Nailsmith_Copilot_20260406_211930.png',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black54,
                        BlendMode.darken,
                      ),
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[900]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),

                // Two-column layout: left = forge info & active operations, right = crafting tabs
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: skill level and active operations
                      Flexible(
                        flex: 4,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Forge: ${state.currentJob.name.split('_').last.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrangeAccent,
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.storefront, size: 16),
                                label: const Text('Go to Shop'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[700],
                                ),
                                onPressed: () => state.toggleShop(true),
                              ),
                              Text(
                                'Hammer Skill: ${state.getSkillLevel(state.currentJob)}',
                                style: TextStyle(color: subTextColor),
                              ),
                              const SizedBox(height: 12),

                              Divider(color: Colors.red[900], height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Active Operations',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              if (activeTasks.isEmpty)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Forge is cold.',
                                    style: TextStyle(color: tabUnselected),
                                  ),
                                )
                              else
                                ...activeTasks
                                    .map(
                                      (task) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.fireplace,
                                              color: Colors.deepOrangeAccent,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${task.equipmentUsed.map((e) => GlobalItemRegistry.getDef(e).name).join(' & ')} active: ${task.remainingTicks} ticks left',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Right column: crafting tabs
                      Flexible(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TabBar(
                              indicatorColor: Colors.deepOrangeAccent,
                              labelColor: Colors.deepOrangeAccent,
                              unselectedLabelColor: tabUnselected,
                              tabs: const [
                                Tab(
                                  text: 'Smelting',
                                  icon: Icon(Icons.fireplace),
                                ),
                                Tab(
                                  text: 'Molding',
                                  icon: Icon(Icons.format_shapes),
                                ),
                                Tab(
                                  text: 'Forging',
                                  icon: Icon(Icons.hardware),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildSmeltingTab(
                                    state,
                                    textColor,
                                    subTextColor,
                                    dropdownColor,
                                    cardColor,
                                  ),
                                  _buildMoldingTab(
                                    state,
                                    ownedMolds,
                                    ownedIngots,
                                    textColor,
                                    subTextColor,
                                    dropdownColor,
                                    cardColor,
                                  ),
                                  _buildForgingTab(
                                    state,
                                    ownedBlanks,
                                    textColor,
                                    subTextColor,
                                    dropdownColor,
                                    cardColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmeltingTab(
    PlayerState state,
    Color textColor,
    Color subTextColor,
    Color dropdownColor,
    Color cardColor,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smelt Ore Into Ingots',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Furnace',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['novice_smelter'],
                      _smlEq,
                      (v) => setState(() => _smlEq = v!),
                      textColor,
                      dropdownColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fuel Source',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['coal', 'wood'],
                      _smlFuel,
                      (v) => setState(() => _smlFuel = v!),
                      textColor,
                      dropdownColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Raw Ore', style: TextStyle(color: subTextColor, fontSize: 12)),
          _buildGenericItemSelector(
            state,
            ['iron_ore', 'tin_ore', 'copper_ore'],
            _smlOre,
            (v) => setState(() => _smlOre = v!),
            textColor,
            dropdownColor,
          ),
          const SizedBox(height: 20),

          Center(
            child: _buildProgressButton(
              state,
              [_smlEq],
              'Ignite Furnace',
              Colors.orangeAccent[700]!,
              cardColor,
              textColor,
              () {
                // Yield is an ingot based on ore selected (iron_ore -> iron_ingot)
                String outputDefId = _smlOre.replaceAll('_ore', '_ingot');
                _submitCraft(
                  state,
                  [_smlEq],
                  null,
                  [_smlOre, _smlFuel],
                  outputDefId,
                  null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoldingTab(
    PlayerState state,
    List<String> ownedMolds,
    List<String> ownedIngots,
    Color textColor,
    Color subTextColor,
    Color dropdownColor,
    Color cardColor,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pour Ingots Into Blanks',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mold',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ownedMolds,
                      _mldEq ?? '',
                      (v) => setState(() => _mldEq = v!),
                      textColor,
                      dropdownColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fuel Source',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['coal', 'wood'],
                      _mldFuel,
                      (v) => setState(() => _mldFuel = v!),
                      textColor,
                      dropdownColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Metal Ingot',
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),
          _buildGenericItemSelector(
            state,
            ownedIngots,
            _mldIngot ?? '',
            (v) => setState(() => _mldIngot = v!),
            textColor,
            dropdownColor,
          ),
          const SizedBox(height: 20),

          Center(
            child: _buildProgressButton(
              state,
              [_mldEq ?? ''],
              'Pour Mold',
              Colors.orangeAccent[700]!,
              cardColor,
              textColor,
              () {
                if (_mldEq == null || _mldIngot == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Missing required mold or ingot!'),
                    ),
                  );
                  return;
                }

                // Molds are not consumed by startCraftingAttempt if they're passed as equipment
                // "mold_nail" -> "blank_nail"
                String outputDefId = _mldEq!.replaceAll('mold_', 'blank_');
                String prefix = GlobalItemRegistry.getDef(
                  _mldIngot!,
                ).name.replaceAll(' Ingot', ''); // "Iron"

                _submitCraft(
                  state,
                  [_mldEq!],
                  null,
                  [_mldIngot!, _mldFuel],
                  outputDefId,
                  prefix,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgingTab(
    PlayerState state,
    List<String> ownedBlanks,
    Color textColor,
    Color subTextColor,
    Color dropdownColor,
    Color cardColor,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hammer Blanks Into Shape',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anvil',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['novice_anvil'],
                      _frgAnvil,
                      (v) => setState(() => _frgAnvil = v!),
                      textColor,
                      dropdownColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hammer',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['novice_hammer'],
                      _frgHammer,
                      (v) => setState(() => _frgHammer = v!),
                      textColor,
                      dropdownColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Metal Blank',
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),
          _buildGenericItemSelector(
            state,
            ownedBlanks,
            _frgBlank ?? '',
            (v) => setState(() => _frgBlank = v!),
            textColor,
            dropdownColor,
          ),
          const SizedBox(height: 20),

          Center(
            child: _buildProgressButton(
              state,
              [_frgAnvil, _frgHammer],
              'Strike Anvil',
              Colors.redAccent[700]!,
              cardColor,
              textColor,
              () {
                if (_frgBlank == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Missing required blank!')),
                  );
                  return;
                }

                ItemInstance? actualBlank = state.getFirstActiveInstance(
                  _frgBlank!,
                );
                String prefix = actualBlank?.customPrefix ?? '';
                String outputDefId = _frgBlank!.replaceAll(
                  'blank_',
                  'metal_',
                ); // metal_nail, metal_saw

                /// Forging cold, consumes only the blank.
                _submitCraft(
                  state,
                  [_frgAnvil, _frgHammer],
                  null,
                  [_frgBlank!],
                  outputDefId,
                  prefix,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitCraft(
    PlayerState state,
    List<String> eq,
    String? ct,
    List<String> mats,
    String out,
    String? prefix,
  ) {
    List<String> cleanMats = mats
        .where((m) => m != 'none' && m.isNotEmpty)
        .toList();
    if (cleanMats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one material!')),
      );
      return;
    }

    bool success = state.startCraftingAttempt(
      equipment: eq,
      container: ct,
      materials: cleanMats,
      outputDefId: out,
      outputCustomPrefix: prefix,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing required items or equipment is busy!'),
        ),
      );
    }
  }

  // Component Helpers
  Widget _buildProgressButton(
    PlayerState state,
    List<String> equipmentUsed,
    String label,
    Color color,
    Color cardColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    // If ANY of the required equipment is busy inside active tasks, disable the button.
    var activeTasks = state.activeTasks.where((t) {
      if (t.ownerPersona != state.currentJob) return false;
      // Check if there is an intersection between the task equipment and this button's required equipment
      return t.equipmentUsed.any((eq) => equipmentUsed.contains(eq));
    });

    bool isBusy = activeTasks.isNotEmpty;
    // Tick loop goes 3 -> 0, so progress is roughly (1 - (remainingTicks/3))
    double progress = isBusy
        ? ((4 - activeTasks.first.remainingTicks) / 4.0).clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      onTap: isBusy ? null : onPressed,
      child: Container(
        width: 250,
        height: 45,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              if (isBusy)
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: color.withOpacity(0.5)),
                ),
              Center(
                child: Text(
                  isBusy ? 'Processing...' : label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenericItemSelector(
    PlayerState state,
    List<String> defIds,
    String currentVal,
    Function(String?) onChanged,
    Color textColor,
    Color dropdownColor,
  ) {
    if (!defIds.contains(currentVal) && defIds.isNotEmpty)
      currentVal = defIds.first;

    return DropdownButton<String>(
      value: defIds.isEmpty ? null : currentVal,
      dropdownColor: dropdownColor,
      isExpanded: true,
      items: defIds.map((String value) {
        int count = state.getActiveInventoryItemCount(value);
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            '${GlobalItemRegistry.getDef(value).name} (Own: $count)',
            style: TextStyle(color: textColor, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
