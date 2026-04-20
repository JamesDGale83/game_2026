import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player_state.dart';
import '../models/item_model.dart';
import '../models/enums.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(context: context, builder: (_) => const InventoryView());
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? Colors.blueGrey[900]! : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.white54 : Colors.black54;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Consumer<PlayerState>(
        builder: (context, state, child) {
          Map<ItemClass, List<ItemInstance>> grouped = {};
          for (var classType in ItemClass.values) {
            grouped[classType] = [];
          }

          for (var item in state.activeInventory) {
            final def = GlobalItemRegistry.getDef(item.defId);
            grouped[def.classification]!.add(item);
          }

          Widget buildItemRow(ItemInstance item) {
            final def = GlobalItemRegistry.getDef(item.defId);
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.displayName,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (def.classification == ItemClass.consumable)
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                          ),
                          onPressed: () {
                            if (state.consumeFood(item)) {
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('You are already fully fed!'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Consume',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.lightGreenAccent
                                  : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    def.description,
                    style: TextStyle(color: subTextColor, fontSize: 10),
                  ),
                  if (item.magicImbued.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        'Imbued: ${item.magicImbued.map((e) => e.name).join(', ')}',
                        style: TextStyle(
                          color: isDark
                              ? Colors.purpleAccent
                              : Colors.deepPurple,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${state.currentJob.name.split('_').last.toUpperCase()} Inventory',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Divider(color: textColor.withOpacity(0.24)),
                Text(
                  'Wealth: ${state.formattedActiveWallet}',
                  style: const TextStyle(color: Colors.amber, fontSize: 16),
                ),
                const SizedBox(height: 10),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ItemClass.values.map((classType) {
                        var itemsInClass = grouped[classType]!;
                        if (itemsInClass.isEmpty)
                          return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                classType.name.toUpperCase(),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.lightGreenAccent
                                      : Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...itemsInClass
                                .map((i) => buildItemRow(i))
                                .toList(),
                            Divider(color: textColor.withOpacity(0.1)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
