import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player_state.dart';
import '../../models/item_model.dart';
import '../../models/enums.dart';

class MerchantPanel extends StatelessWidget {
  const MerchantPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? Colors.blueGrey[900]! : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color cardColor = isDark ? Colors.blueGrey[800]! : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amberAccent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Global Import/Export Market',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Return to Workspace'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.red[900] : Colors.red,
                ),
                onPressed: () => context.read<PlayerState>().toggleShop(false),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.amberAccent,
                    labelColor: Colors.amberAccent,
                    unselectedLabelColor: textColor.withOpacity(0.54),
                    tabs: const [
                      Tab(text: "Buy Materials"),
                      Tab(text: "Buy Equipment"),
                      Tab(text: "Sell Wares"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBuyTab(
                          context,
                          ItemClass.material,
                          textColor,
                          cardColor,
                          isDark,
                        ),
                        _buildBuyTab(
                          context,
                          ItemClass.equipment,
                          textColor,
                          cardColor,
                          isDark,
                        ),
                        _buildSellTab(context, textColor, cardColor, isDark),
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
  }

  Widget _buildBuyTab(
    BuildContext context,
    ItemClass category,
    Color textColor,
    Color cardColor,
    bool isDark,
  ) {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        final jobLevel = state.getSkillLevel(state.currentJob);

        List<ItemInstance> availableItems = [];
        for (var item in state.marketInventory) {
          final def = GlobalItemRegistry.getDef(item.defId);
          if (def.classification == category &&
              jobLevel >= def.requiredMerchantLevel) {
            availableItems.add(item);
          }
        }

        if (availableItems.isEmpty) {
          return Center(
            child: Text(
              'No goods available for your level.',
              style: TextStyle(color: textColor),
            ),
          );
        }

        return ListView.builder(
          itemCount: availableItems.length,
          itemBuilder: (context, index) {
            final item = availableItems[index];
            final def = GlobalItemRegistry.getDef(item.defId);
            final qtyString = PlayerState.infiniteItems.contains(item.defId)
                ? '∞'
                : item.quantity.toString();
            bool canAfford =
                (state.wallets[state.currentJob] ?? 0) >= def.baseValue;

            return Card(
              color: cardColor,
              child: ListTile(
                title: Text(
                  '${item.displayName} (Market: $qtyString)',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Costs: ${state.formatCurrency(def.baseValue)}\n${def.description}',
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
                trailing: ElevatedButton(
                  onPressed: canAfford
                      ? () {
                          if (state.buyFromMarket(item.defId, def.baseValue)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Bought ${item.displayName}!'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed out of stock.'),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.green[800] : Colors.green,
                  ),
                  child: const Text('Buy'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSellTab(
    BuildContext context,
    Color textColor,
    Color cardColor,
    bool isDark,
  ) {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        if (state.activeInventory.isEmpty) {
          return Center(
            child: Text(
              'Your inventory is empty.',
              style: TextStyle(color: textColor),
            ),
          );
        }

        return ListView.builder(
          itemCount: state.activeInventory.length,
          itemBuilder: (context, index) {
            final item = state.activeInventory[index];
            final def = GlobalItemRegistry.getDef(item.defId);
            int sellPrice = (def.baseValue * 0.7).floor();
            if (item.magicImbued.isNotEmpty)
              sellPrice = (sellPrice * 1.5).floor();

            return Card(
              color: cardColor,
              child: ListTile(
                title: Text(
                  '${item.displayName} (Owned: ${item.quantity})',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Sells for: ${state.formatCurrency(sellPrice)}',
                  style: const TextStyle(color: Colors.amber),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    if (state.sellToMarket(item, sellPrice)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sold ${item.displayName}!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                  ),
                  child: const Text('Sell'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
