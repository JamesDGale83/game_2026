import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player_state.dart';
import '../../models/item_model.dart';
import '../../models/enums.dart';

class ApothecaryPanel extends StatefulWidget {
  const ApothecaryPanel({Key? key}) : super(key: key);

  @override
  State<ApothecaryPanel> createState() => _ApothecaryPanelState();
}

class _ApothecaryPanelState extends State<ApothecaryPanel> {
  // Powders State
  String _pwdEq = 'smooth_rock';
  String _pwdCont = 'empty_pouch';
  String _pwdMatA = 'basil';

  // Salves State
  String _slvEq = 'cauldron';
  String _slvCont = 'wooden_tin';
  String _slvBase = 'animal_fat';
  String _slvMatA = 'basil';

  // Potions State
  String _potEq = 'cauldron';
  String _potCont = 'empty_gourd_flask';
  String _potMatA = 'basil';
  String _potMatB = 'none';
  String _potMatC = 'none';

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark
        ? Colors.green[900]!.withOpacity(0.8)
        : Colors.green[50]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.white70 : Colors.black54;
    Color cardColor = isDark ? Colors.blueGrey[900]! : Colors.white;
    Color dropdownColor = isDark ? Colors.blueGrey[800]! : Colors.grey[100]!;
    Color tabUnselected = isDark ? Colors.white54 : Colors.black45;

    return Consumer<PlayerState>(
      builder: (context, state, child) {
        final activeTasks = state.activeTasks.where(
          (t) => t.ownerPersona == state.currentJob,
        );

        return DefaultTabController(
          length: 3,
          child: Container(
            constraints: const BoxConstraints(minHeight: 750),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.lightGreenAccent, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 4,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apothecary Station',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.storefront, size: 16),
                                label: const Text('Go to Shop'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? Colors.amber[700]
                                      : Colors.amber[600],
                                ),
                                onPressed: () => state.toggleShop(true),
                              ),
                              Text(
                                'Skill Level: ${state.getSkillLevel(JobType.apothecary)}',
                                style: TextStyle(color: subTextColor),
                              ),
                              const SizedBox(height: 12),

                              Divider(
                                color: textColor.withOpacity(0.24),
                                height: 20,
                              ),
                              Text(
                                'Active Processing',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              if (activeTasks.isEmpty)
                                Text(
                                  'No operations active.',
                                  style: TextStyle(color: tabUnselected),
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
                                              Icons.timer,
                                              color: Colors.lightGreenAccent,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${task.equipmentUsed.map((e) => GlobalItemRegistry.getDef(e).name).join(', ')}: ${task.remainingTicks} ticks left',
                                                style: TextStyle(
                                                  color: textColor,
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

                      Flexible(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TabBar(
                              indicatorColor: Colors.lightGreenAccent,
                              labelColor: isDark
                                  ? Colors.lightGreenAccent
                                  : Colors.green[800],
                              unselectedLabelColor: tabUnselected,
                              tabs: const [
                                Tab(text: 'Powders', icon: Icon(Icons.grain)),
                                Tab(text: 'Salves', icon: Icon(Icons.spa)),
                                Tab(text: 'Potions', icon: Icon(Icons.science)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildPowdersTab(
                                    state,
                                    textColor,
                                    subTextColor,
                                    dropdownColor,
                                    cardColor,
                                  ),
                                  _buildSalvesTab(
                                    state,
                                    textColor,
                                    subTextColor,
                                    dropdownColor,
                                    cardColor,
                                  ),
                                  _buildPotionsTab(
                                    state,
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

  Widget _buildPowdersTab(
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
            'Grind Powders',
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
                      'Mortar Tool',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['smooth_rock', 'mortar_pestle'],
                      _pwdEq,
                      (v) => setState(() => _pwdEq = v!),
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
                      'Pouch',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['empty_pouch'],
                      _pwdCont,
                      (v) => setState(() => _pwdCont = v!),
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
            'Herb to Grind',
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),
          _buildHerbSelector(
            state,
            _pwdMatA,
            (v) => setState(() => _pwdMatA = v!),
            textColor,
            dropdownColor,
          ),
          const SizedBox(height: 16),

          Center(
            child: _buildProgressButton(
              state,
              _pwdEq,
              'Grind Powder',
              Colors.greenAccent[700]!,
              cardColor,
              textColor,
              () {
                _submitCraft(state, _pwdEq, _pwdCont, [
                  _pwdMatA,
                ], 'powder_draft');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalvesTab(
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
            'Mix Salves',
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
                      'Heater',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['cauldron'],
                      _slvEq,
                      (v) => setState(() => _slvEq = v!),
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
                      'Container',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['wooden_tin'],
                      _slvCont,
                      (v) => setState(() => _slvCont = v!),
                      textColor,
                      dropdownColor,
                    ),
                  ],
                ),
              ),
            ],
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
                    const Text(
                      'Binding Base',
                      style: TextStyle(color: Colors.amberAccent, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['animal_fat'],
                      _slvBase,
                      (v) => setState(() => _slvBase = v!),
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
                      'Active Herb',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildHerbSelector(
                      state,
                      _slvMatA,
                      (v) => setState(() => _slvMatA = v!),
                      textColor,
                      dropdownColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Center(
            child: _buildProgressButton(
              state,
              _slvEq,
              'Mix Salve',
              Colors.greenAccent[700]!,
              cardColor,
              textColor,
              () {
                if (_slvBase.isEmpty || _slvBase == 'none') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Missing required binding base!'),
                    ),
                  );
                  return;
                }
                _submitCraft(state, _slvEq, _slvCont, [
                  _slvMatA,
                  _slvBase,
                ], 'salve_draft');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotionsTab(
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
            'Brew Potions',
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
                      'Boiler',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['cauldron', 'alembic'],
                      _potEq,
                      (v) => setState(() => _potEq = v!),
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
                      'Flask',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    _buildGenericItemSelector(
                      state,
                      ['empty_gourd_flask'],
                      _potCont,
                      (v) => setState(() => _potCont = v!),
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
            'Materials (Up to 3)',
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Expanded(
                child: _buildHerbSelector(
                  state,
                  _potMatA,
                  (v) => setState(() => _potMatA = v!),
                  textColor,
                  dropdownColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHerbSelector(
                  state,
                  _potMatB,
                  (v) => setState(() => _potMatB = v!),
                  textColor,
                  dropdownColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHerbSelector(
                  state,
                  _potMatC,
                  (v) => setState(() => _potMatC = v!),
                  textColor,
                  dropdownColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Center(
            child: _buildProgressButton(
              state,
              _potEq,
              'Brew Potion',
              Colors.greenAccent[700]!,
              cardColor,
              textColor,
              () {
                _submitCraft(state, _potEq, _potCont, [
                  _potMatA,
                  _potMatB,
                  _potMatC,
                ], 'custom_potion');
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitCraft(
    PlayerState state,
    String eq,
    String ct,
    List<String> mats,
    String out,
  ) {
    List<String> cleanMats = mats.where((m) => m != 'none').toList();
    if (cleanMats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one material!')),
      );
      return;
    }

    bool success = state.startCraftingAttempt(
      equipment: [eq],
      container: ct,
      materials: cleanMats,
      outputDefId: out,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing required items or equipment is busy!'),
        ),
      );
    }
  }

  Widget _buildProgressButton(
    PlayerState state,
    String equipmentUsed,
    String label,
    Color progressColor,
    Color cardColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    var activeTasks = state.activeTasks.where(
      (t) =>
          t.equipmentUsed.contains(equipmentUsed) &&
          t.ownerPersona == state.currentJob,
    );
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
          border: Border.all(color: progressColor, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              if (isBusy)
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: progressColor.withOpacity(0.5)),
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

  Widget _buildHerbSelector(
    PlayerState state,
    String currentVal,
    Function(String?) onChanged,
    Color textColor,
    Color dropdownColor,
  ) {
    List<ItemDef> herbs = GlobalItemRegistry.getAllDefs()
        .where(
          (i) =>
              i.classification == ItemClass.material &&
              (i.usableBy?.contains(JobType.apothecary) ?? false) &&
              i.id !=
                  'animal_fat', // separate binding bases out of generic herb selects
        )
        .toList();

    List<String> options = ['none', ...herbs.map((h) => h.id)];

    if (!options.contains(currentVal)) {
      currentVal = 'none'; // Fallback
    }

    return DropdownButton<String>(
      value: currentVal,
      dropdownColor: dropdownColor,
      isExpanded: true,
      items: options.map((String value) {
        int count = value == 'none'
            ? 0
            : state.getActiveInventoryItemCount(value);
        String label = value == 'none'
            ? 'None'
            : '${GlobalItemRegistry.getDef(value).name} ($count)';
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            label,
            style: TextStyle(color: textColor, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
