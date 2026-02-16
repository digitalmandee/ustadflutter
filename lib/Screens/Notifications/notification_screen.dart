import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom widgets/app_bar.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Providers/notification/notification_provider.dart';
import 'package:ustaad/Screens/Chats/single_chat_tutor.dart';
import 'package:ustaad/Screens/Drawer/Contracts/contracts.dart';
import 'package:ustaad/Screens/Drawer/Earnings/tutor_earning_dashboard.dart';
import 'package:ustaad/config/keys/global.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool selectionMode = false;
  Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();
    // final provider = Provider.of<NotificationProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications(context);
    });
  }

  void _deleteSelected(context) async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);

    await provider.deleteNotifications(
      context,
      selectedIds.toList(),
    );

    setState(() {
      selectedIds.clear();
      selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar1(
        title:
            selectionMode ? "${selectedIds.length} selected" : "Notifications",
        backArrow: true,
        isDel: selectedIds.isNotEmpty ? true : false,
        onDeletePressed: () => _deleteSelected(context),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return GifLoader();
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text("No notifications found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              final notiType = provider.notifications[index]["type"];
              final String id = notification["id"];

              final bool isSelected = selectedIds.contains(id);

              return GestureDetector(
                onLongPress: () {
                  setState(() {
                    selectionMode = true;
                    selectedIds.add(id);
                  });
                },
                onTap: () {
                  if (!selectionMode) {
                    if (notiType == "PAYMENT_STATUS_UPDATE") {
                      push(context, TutorEarningScreen());
                    } else if (notiType == "NEW_MESSAGE" ||
                        notiType == "OFFER_RECEIVED" ||
                        notiType == "OFFER_REJECTED" ||
                        notiType == "OFFER_ACCEPTED") {
                      push(
                          context,
                          SingleChatScreen(
                              conversationId:
                                  '${notification["metadata"]["conversationId"]}',
                              userId: globalUserId!,
                              recieverName:
                                  '${notification["metadata"]["senderName"]}',
                              recieverId:
                                  '${notification["metadata"]["recieverId"]}',
                              image: '${notification["metadata"]["image"]}'));
                    } else if (notiType == "CONTRACT_DISPUTED" ||
                        notiType == "CONTRACT_COMPLETED" ||
                        notiType == "CONTRACT_CANCELLED") {
                      push(
                          context,
                          ContractScreen(
                            isParentSide:
                                globalUserRole == "PARENT" ? true : false,
                          ));
                    }
                  }

                  if (selectionMode) {
                    setState(() {
                      if (isSelected) {
                        selectedIds.remove(id);
                      } else {
                        selectedIds.add(id);
                      }

                      if (selectedIds.isEmpty) {
                        selectionMode = false;
                      }
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.only(
                      left: selectionMode == true ? 0 : 16,
                      right: 16,
                      top: 16,
                      bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: AppTheme.primaryCOlor,
                        width: 4,
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectionMode)
                        Checkbox(
                          value: isSelected,
                          activeColor: AppTheme.appColor,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedIds.add(id);
                              } else {
                                selectedIds.remove(id);
                              }

                              if (selectedIds.isEmpty) {
                                selectionMode = false;
                              }
                            });
                          },
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification["title"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification["body"] ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification["sentAt"] != null
                                  ? formatDate(notification["sentAt"])
                                  : "",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
        },
      ),
    );
  }

  static String formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} "
          "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }
}
