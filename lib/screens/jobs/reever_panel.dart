import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player_state.dart';
import '../../models/item_model.dart';
import '../../models/enums.dart';

class ReeverPanel extends StatelessWidget {
  const ReeverPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        bool isDark = Theme.of(context).brightness == Brightness.dark;
        Color? bgColor = isDark
            ? Colors.indigo[900]?.withOpacity(0.85)
            : Colors.blue[50];
        Color textColor = isDark ? Colors.white : Colors.black87;
        Color cardColor = isDark ? Colors.blueGrey[800]! : Colors.white;

        // Count total houses
        int houses =
            (state.constructedBuildings['small_house'] ?? 0) +
            ((state.constructedBuildings['large_house'] ?? 0) * 3);

        return Container(
          constraints: const BoxConstraints(
            minHeight: 750,
          ),
          
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.lightBlueAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reever: Town Governance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.storefront, size: 16),
                    label: const Text('Visit Import Market'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                    ),
                    onPressed: () => state.toggleShop(true),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Town Morale: ${state.townMorale}/100',
                    style: TextStyle(
                      color: state.townMorale > 50
                          ? Colors.lightGreen
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Population Capacity: $houses',
                    style: TextStyle(color: textColor.withOpacity(0.7)),
                  ),
                  Text(
                    'Next Tax: ${state.taxCountdown}s',
                    style: const TextStyle(color: Colors.amber),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: Colors.lightBlueAccent,
                        labelColor: Colors.lightBlueAccent,
                        unselectedLabelColor: textColor.withOpacity(0.54),
                        tabs: const [
                          Tab(
                            text: 'Treasury & Food Stores',
                            icon: Icon(Icons.food_bank),
                          ),
                          Tab(
                            text: 'Town Contracting',
                            icon: Icon(Icons.handyman),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 2, // Give more space to the tab content
                        child: TabBarView(
                          children: [
                            _buildTreasuryTab(state, textColor, cardColor),
                            _buildContractingTab(
                              context,
                              state,
                              textColor,
                              cardColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTreasuryTab(
    PlayerState state,
    Color textColor,
    Color cardColor,
  ) {
    List<String> townResources = [
      'grain',
      'veggies',
      'meat',
      'bread',
      'lumber',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight
            ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reever Private Reserves',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Divider(color: textColor.withOpacity(0.24)),
        
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: townResources.map((id) {
                  int qty = state.getActiveInventoryItemCount(id);
                  final def = GlobalItemRegistry.getDef(id);
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: textColor.withOpacity(0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          def.name,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Stored: $qty',
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        );
      }
    );
  }

  Widget _buildContractingTab(
    BuildContext context,
    PlayerState state,
    Color textColor,
    Color cardColor,
  ) {
    return SingleChildScrollView(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // LEFT COLUMN (existing housing)
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commission New Housing',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Divider(color: textColor.withOpacity(0.24)),

            _buildContractCard(
              context,
              state,
              'Small House',
              'small_house',
              Icons.house,
              500,
              {'lumber': 5, 'metal_nail': 10},
              textColor,
              cardColor,
            ),
            _buildContractCard(
              context,
              state,
              'Large Tenement',
              'large_house',
              Icons.apartment,
              2000,
              {'lumber': 25, 'metal_nail': 50},
              textColor,
              cardColor,
            ),
            _buildContractCard(
              context,
              state,
              'Town Park',
              'park',
              Icons.park,
              1000,
              {'lumber': 10},
              textColor,
              cardColor,
            ),
          ],
        ),
      ),

      const SizedBox(width: 12),

      // RIGHT COLUMN (new stuff)
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Town Infrastructure',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Divider(color: textColor.withOpacity(0.24)),

            _buildContractCard(
              context,
              state,
              'Build Farm',
              'farm',
              Icons.agriculture,
              800,
              {'lumber': 10},
              textColor,
              cardColor,
            ),
            _buildContractCard(
              context,
              state,
              'Construct Shop',
              'shop',
              Icons.store,
              1200,
              {'lumber': 15, 'metal_nail': 20},
              textColor,
              cardColor,
            ),
            _buildContractCard(
              context,
              state,
              'Blacksmith',
              'blacksmith',
              Icons.build,
              1500,
              {'lumber': 20, 'metal_nail': 40},
              textColor,
              cardColor,
            ),
          ],
        ),
      ),
    ],
  ),
);

  }

  Widget _buildContractCard(
    BuildContext context,
    PlayerState state,
    String name,
    String id,
    IconData icon,
    int cost,
    Map<String, int> mats,
    Color textColor,
    Color cardColor,
  ) {
    int owned = state.constructedBuildings[id] ?? 0;

    bool canBuild = (state.wallets[JobType.reever] ?? 0) >= cost;
    for (var m in mats.entries) {
      if (state.getActiveInventoryItemCount(m.key) < m.value) canBuild = false;
    }

    return Card(
      color: cardColor,
      child: ListTile(
        leading: Icon(icon, color: Colors.lightBlueAccent, size: 32),
        title: Text(
          '$name (Built: $owned)',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Costs: ${cost}C | Needs: ${mats.keys.map((k) => "${mats[k]}x ${GlobalItemRegistry.getDef(k).name}").join(', ')}',
          style: TextStyle(color: textColor.withOpacity(0.7)),
        ),
        trailing: ElevatedButton(
          onPressed: canBuild
              ? () {
                  state.buildStructure(id, cost, mats);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Constructed $name!')));
                }
              : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
          child: const Text('Build'),
        ),
      ),
    );
  }
}
