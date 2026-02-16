import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/base_image.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:ustaad/config/keys/global.dart';

import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Providers/Chat/all_chat_provider.dart';
import 'package:ustaad/Screens/Chats/single_chat_tutor.dart';
import 'package:ustaad/Screens/Drawer/drawer.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _search = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _searchFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() {}); // icon show/hide ke liye
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AllChatProvider>(context, listen: false).fetchChats(context);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocusNode.dispose(); // ✅ important
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final tutorProvider = context.watch<TutorDashBoardProvider>();
    final parentProvider = context.watch<ParentProfileProvider>();

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SideMenuDrawer(
        crossOnTap: () {
          _scaffoldKey.currentState?.closeEndDrawer();
        },
        isTutor: globalUserRole == "TUTOR" ? true : false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/Background.png",
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              CustomAppBar(
                taskSummary: globalUserRole == "TUTOR"
                    ? tutorProvider.tasks
                    : parentProvider.tasks,
                onMenuTap: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: isKeyboardOpen ? 0 : 65,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.appText("Chat",
                          fontWeight: FontWeight.w600, fontSize: 22),
                      const SizedBox(height: 15),
                      CustomAppTextField(
                        texthint: "Search",
                        controller: _search,
                        onChanged: (value) {
                          context.read<AllChatProvider>().filterChats(value);
                        },
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            "assets/images/search.png",
                            color: Color(0xffA6ADBF),
                          ),
                        ),
                        suffix: _search.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _search.clear();
                                  context
                                      .read<AllChatProvider>()
                                      .filterChats("");
                                },
                                child: const Icon(Icons.close, size: 18),
                              )
                            : null,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Consumer<AllChatProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading) return GifLoader();

                          if (provider.chats.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Center(
                                  child: AppText.appText("No chat found")),
                            );
                          }

                          if (provider.filteredChats.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Center(
                                  child: AppText.appText("No matching result")),
                            );
                          }

                          return Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: provider.filteredChats.length,
                              itemBuilder: (context, index) {
                                final chat = provider.filteredChats[index];
                                print(
                                    "${chat.lastMsg} here is the last message");
                                return Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SingleChatScreen(
                                                image: chat.image!,
                                                conversationId: chat.id,
                                                userId: globalUserId!,
                                                recieverId: chat.participantId,
                                                recieverName: chat.name,
                                              ),
                                            ),
                                          ).then((_) =>
                                              provider.fetchChats(context));
                                        },
                                        child: chat.lastMsg == null
                                            ? SizedBox.shrink()
                                            : ChatTile(
                                                name: chat.name,
                                                message: chat.lastMsg ?? '',
                                                msgType: chat.msgType,
                                                time: chat.lastMsgTime == null
                                                    ? ""
                                                    : formatTimestamp(
                                                        chat.lastMsgTime!),
                                                duration: chat.duration,
                                                image: chat.image!,
                                                isOnline: true,
                                                unreadCount:
                                                    chat.unreadCount ?? 0,
                                              ),
                                      ),
                                    ),
                                    chat.lastMsg == null
                                        ? SizedBox.shrink()
                                        : Divider(
                                            color: AppTheme.dividerColor,
                                          )
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatTimestamp(DateTime utcDateTime) {
    final dateTime = utcDateTime.toLocal();
    final formatter = DateFormat('h:mm a');
    return formatter.format(dateTime);
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String image;
  final bool isOnline;
  final int unreadCount;
  final String? duration;
  final String? msgType;

  const ChatTile({
    super.key,
    required this.name,
    this.duration,
    this.msgType,
    required this.message,
    required this.time,
    required this.image,
    required this.isOnline,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: image == "" || image.isEmpty
                ? ClipOval(
                    child: Image.asset(globalUserRole == 'TUTOR'
                        ? "assets/images/parentProfile.jpeg"
                        : "assets/images/tutorProfile.jpeg"))
                : image.startsWith('http')
                    ? ClipOval(
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(globalUserRole == 'TUTOR'
                                ? "assets/images/parentProfile.jpeg"
                                : "assets/images/tutorProfile.jpeg");
                          },
                        ),
                      )
                    : ClipOval(
                        child: Base64ImageWidget(base64String: image),
                      )),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.appText(
                name,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              const SizedBox(height: 4),
              AppText.appText(
                message == ""
                    ? "Start Chat"
                    : msgType == "AUDIO"
                        ? "$message (${formatDuration(duration)})"
                        : message,
                maxlines: 1,
                overflow: TextOverflow.ellipsis,
                fontSize: 14,
                textColor: unreadCount.toString() == "0"
                    ? Colors.grey
                    : AppTheme.black,
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Column(
          children: [
            AppText.appText(
              time,
              fontSize: 12,
              textColor: Colors.grey,
            ),
            const SizedBox(height: 4),
            unreadCount.toString() == "0"
                ? const SizedBox()
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.appColor,
                      border: Border.all(width: 1, color: AppTheme.appColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: AppText.appText(
                        unreadCount.toString(),
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        textColor: AppTheme.white,
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  String formatDuration(String? seconds) {
    if (seconds == null) return "0:00";

    final int totalSeconds = int.tryParse(seconds) ?? 0;
    final int minutes = totalSeconds ~/ 60;
    final int remainingSeconds = totalSeconds % 60;

    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
