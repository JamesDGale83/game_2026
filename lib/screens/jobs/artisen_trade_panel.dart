import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player_state.dart';
import '../../models/item_model.dart';
import '../../models/enums.dart';

class MerchantPanel extends StatefulWidget {
  const MerchantPanel({Key? key}) : super(key: key);

  @override
  State<MerchantPanel> createState() => _MerchantPanelState();
}

class _MerchantPanelState extends State<MerchantPanel> {
  int _activeTab = 0; // 0 = Buy Materials, 1 = Buy Equipment, 2 = Sell Wares

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        final merchantLevel = state.getSkillLevel(JobType.merchant);

        List<ItemDef> availableMaterials = GlobalItemRegistry.getAllDefs()
            .where(
              (def) =>
                  def.requiredMerchantLevel <= merchantLevel &&
                  def.classification == ItemClass.material,
            )
            .toList();

        List<ItemDef> availableEquipment = GlobalItemRegistry.getAllDefs()
            .where(
              (def) =>
                  def.requiredMerchantLevel <= merchantLevel &&
                  (def.classification == ItemClass.equipment ||
                      def.classification == ItemClass.container ||
                      def.classification == ItemClass.blueprint),
            )
            .toList();

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.brown[900]?.withOpacity(0.9),
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
                    'Marketplace',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => state.toggleShop(false),
                    child: const Text(
                      'Leave Shop',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '${state.currentJob.name.split('_').last.toUpperCase()}\'s Wealth: ${state.formattedActiveWallet}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Market Level: $merchantLevel',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Divider(color: Colors.white24, height: 20),

              // Toggle Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _activeTab = 0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeTab == 0
                            ? Colors.green
                            : Colors.grey[800],
                      ),
                      child: const Text('Buy Materials'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => _activeTab = 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeTab == 1
                            ? Colors.green
                            : Colors.grey[800],
                      ),
                      child: const Text('Buy Equipment'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => _activeTab = 2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeTab == 2
                            ? Colors.orange
                            : Colors.grey[800],
                      ),
                      child: const Text('Sell Wares'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: _buildActiveTab(
                    context,
                    state,
                    availableMaterials,
                    availableEquipment,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveTab(
    BuildContext context,
    PlayerState state,
    List<ItemDef> materials,
    List<ItemDef> equipment,
  ) {
    if (_activeTab == 0) return _buildBuyList(context, state, materials);
    if (_activeTab == 1) return _buildBuyList(context, state, equipment);
    return _buildSellList(context, state);
  }

  Widget _buildBuyList(
    BuildContext context,
    PlayerState state,
    List<ItemDef> available,
  ) {
    if (available.isEmpty)
      return const Text(
        'Market is empty.',
        style: TextStyle(color: Colors.white),
      );

    return Column(
      children: available.map((def) {
        int cost = def.baseValue;
        int marketHas = state.getMarketInventoryItemCount(def.id);
        if (marketHas <= 0) return const SizedBox.shrink(); // Hide out of stock

        String stockLabel = marketHas > 900 ? '∞' : '$marketHas';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${def.name} (Stock: $stockLabel)',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      def.description,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '-${cost}c',
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (!state.buyFromMarket(def.id, cost)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot buy. Not enough funds.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Buy 1'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSellList(BuildContext context, PlayerState state) {
    if (state.activeInventory.isEmpty) {
      return const Text(
        'Your inventory is empty.',
        style: TextStyle(color: Colors.white),
      );
    }

    return Column(
      children: state.activeInventory.map((item) {
        final def = GlobalItemRegistry.getDef(item.defId);
        int sellPrice = def.baseValue;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.displayName} (x${item.quantity})',
                      style: const TextStyle(color: Colors.amberAccent),
                    ),
                    if (item.magicImbued.isNotEmpty)
                      Text(
                        'Imbued: ${item.magicImbued.map((e) => e.name).join(', ')}',
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '+${sellPrice}c',
                style: const TextStyle(color: Colors.greenAccent),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (!state.sellToMarket(item, sellPrice)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot sell.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Sell 1'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
