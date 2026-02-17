import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/base_image.dart';
import 'package:ustaad/Providers/Chat/all_chat_provider.dart';
import 'package:ustaad/Screens/Chats/parent_card.dart';
import 'package:ustaad/Screens/Drawer/drawer.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Profile/parent_profile.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Profile/tutor_profile.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Chats/bubble_widget.dart';
import 'package:ustaad/Screens/Chats/chat_modet.dart';
import 'package:ustaad/Screens/Chats/offer_sheet.dart';
import 'package:ustaad/Screens/Chats/socket.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class SingleChatScreen extends StatefulWidget {
  final String conversationId;
  final String userId;
  final String recieverId;
  final String? recieverName;
  final String image;

  const SingleChatScreen({
    super.key,
    required this.conversationId,
    required this.userId,
    required this.recieverId,
    this.recieverName,
    required this.image,
  });

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<ChatMessage> messages = [];
  late final RecorderController recorderController;
  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();
  int page = 1;
  bool hasMore = true;
  bool isFetching = false;
  final socketService = SocketService();
  bool _isSocketInitialized = false;
  Timer? _reconnectTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRoomJoined = false;
  bool _showOptions = false;
  ChatMessage? _previewMessage;
  File? selectedFile;
  // final record = AudioRecorder();
  bool isRecording = false;
  List<dynamic> childrensData = [];
  bool isConversationLoading = false;
  int _previewAudioDuration = 0;

  File? recordedFile;
  Timer? _recordTimer;
  int _recordDuration = 0;
  File? _previewAudio;
  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
    if (globalUserRole == "TUTOR") {
      _fetchConversationData();
    }
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 192000;
    _initializeSocket();
  }

  Future<void> markAllread() async {
    try {
      final response = await dio.patch(
        path: '${AppUrls.markAllRead}${widget.conversationId}/read',
      );

      if (response.statusCode == 200) {
        Provider.of<AllChatProvider>(context, listen: false)
            .fetchChats(context);
      }
    } catch (e) {
      debugPrint("❌ Error fetching conversation data: $e");
    } finally {
      setState(() => isConversationLoading = false);
    }
  }

  Future<void> _fetchConversationData() async {
    if (isConversationLoading) return;

    setState(() => isConversationLoading = true);

    try {
      final response = await dio.get(
        path: '${AppUrls.getConverstionbyID}${widget.conversationId}',
      );

      if (response.statusCode == 200) {
        setState(() {
          childrensData = response.data['data']["children"];
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching conversation data: $e");
    } finally {
      setState(() => isConversationLoading = false);
    }
  }

  void _initializeSocket() async {
    print("Here socket is Initializing....!");

    if (_isSocketInitialized) return;

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString(PrefKey.authorization);
    if (globalToken == null) {
      return;
    } else {
      _connectToSocket(globalToken!);
    }
  }

  void _connectToSocket(String token) {
    if (_isSocketInitialized) return;
    _isSocketInitialized = true;
    socketService.connect(
      token: token,
      userId: globalUserId!,
      onConnected: () {
        debugPrint("🔌 Connected or Reconnected, joining room...");
        socketService.joinConversation(widget.conversationId);
        setState(() {
          _isRoomJoined = true;
        });
        loadChatHistory();
        markAllread();
      },
      onDeleted: (messageId) {
        _handleDeletedMessage(messageId);
      },
      onMessageReceived: (data) {
        if (!mounted) return;
        _handleNewMessage(data);
      },
      onDisconnected: () {
        if (!mounted) return;
        setState(() {
          _isRoomJoined = false;
        });
      },
    );
  }

  void _handleDeletedMessage(String messageId) {
    if (!mounted) return;

    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final oldMsg = messages[index];
      setState(() {
        messages[index] = oldMsg.copyWith(
          text: "This message was deleted",
          type: "TEXT",
          isPending: false,
        );
      });
    }

    debugPrint("🗑 Message marked as deleted: $messageId");
  }

  void _deleteMessage(ChatMessage message) {
    final now = DateTime.now();
    final diff = now.difference(message.createdAt);

    debugPrint("Delete diff: ${diff.inSeconds}s");

    if (diff.inSeconds > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can delete messages only within 1 minute."),
        ),
      );
      return;
    }

    socketService.deleteMessage(message.id);
  }

  void _playSendSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/msg_beep.mp3'));
    } catch (e) {
      debugPrint("Error playing send sound: $e");
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    int? audioLength;
    if (!mounted) return;

    final messageId = data['id'] ?? data['_id'];
    final senderId = data['senderId'];
    final msgText = data["content"] ?? "";
    final msgType = data["type"] ?? "TEXT";
    final offerData = data['metadata']?["offer"]; // ✅ Safe access
    final fileText = data["metadata"]?["fileOriginalName"];
    if (msgType == "AUDIO") {
      audioLength = int.tryParse(data["metadata"]?["duration"]);
    }
    // ✅ Safe access

    if (senderId == widget.userId) {
      final index = messages.indexWhere(
        (m) => m.text == msgText && m.type == msgType,
      );
      if (index != -1) {
        print("audiolength is this $audioLength");
        setState(() {
          messages[index] = messages[index].copyWith(
              id: messageId,
              isPending: false,
              offer: offerData,
              fileText: fileText,
              audioDuration: audioLength);
        });
      }
    } else {
      final newMessage = ChatMessage(
        id: messageId,
        text: msgText,
        time: _formatTime(data['createdAt']),
        createdAt: DateTime.parse(data['createdAt']).toLocal(),
        isMe: senderId == widget.userId,
        fileText: fileText,
        audioDuration: audioLength,
        type: msgType,
        isPending: false,
        offer: offerData,
      );
      setState(() {
        messages.insert(0, newMessage);
        markAllread();
      });
    }
  }

  void sendMessage(String text) async {
    final tempId = "temp-${DateTime.now().millisecondsSinceEpoch}";
    final message = {
      "conversationId": widget.conversationId,
      "content": text,
      "type": "TEXT",
    };

    socketService.sendMessage(message);
    final now = DateTime.now();
    setState(() {
      messages.insert(
        0,
        ChatMessage(
            id: tempId,
            text: text,
            time: _formatTime(DateTime.now().toIso8601String()),
            isMe: true,
            createdAt: now,
            isPending: true,
            type: "TEXT"),
      );
    });
    _playSendSound();
    _messageController.clear();
  }

  void loadChatHistory() async {
    if (!hasMore || isFetching) return;

    isFetching = true;

    try {
      final response = await dio.get(
        path: '${AppUrls.getConverstion}${widget.conversationId}?page=$page',
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data['data']['messages'];

        final newMessages = messagesJson
            .map((msg) => ChatMessage(
                id: msg['id'],
                isPending: false,
                text: msg['content'] ?? '',
                time: _formatTime(msg['createdAt']),
                createdAt: DateTime.parse(msg['createdAt']).toLocal(),
                isMe: msg['senderId'] == widget.userId,
                type: msg["type"],
                audioDuration: msg["metadata"]?["duration"] != null
                    ? int.tryParse(msg["metadata"]!["duration"].toString())
                    : null,
                fileText: msg["metadata"]?["fileOriginalName"],
                offer: msg["metadata"]?["offer"]))
            .toList();

        setState(() {
          messages.addAll(newMessages);
          page++;
          if (newMessages.length < 20) hasMore = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching messages: $e");
    } finally {
      isFetching = false;
    }
  }

  String _formatTime(String iso) {
    try {
      final dateTime = DateTime.parse(iso).toLocal();
      int hour = dateTime.hour % 12;
      hour = hour == 0 ? 12 : hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return "$hour:$minute $period";
    } catch (e) {
      return '';
    }
  }

  Future<void> startRecording() async {
    final dir = Directory.systemTemp;
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.mp3';
    // await record.start(
    //   const RecordConfig(
    //       encoder: AudioEncoder.aacLc, bitRate: 192000, sampleRate: 44100),
    //   path: path,
    // );

    await recorderController.record(path: path); // 👈 important

    setState(() {
      isRecording = true;
      _recordDuration = 0;
    });

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  Future<void> stopRecording({bool cancelled = false}) async {
    final path = await recorderController.stop();
    // await recorderController.stop(); // 👈 important
    _recordTimer?.cancel();

    setState(() => isRecording = false);

    if (path != null && !cancelled) {
      setState(() {
        _previewAudio = File(path);
        _previewAudioDuration = _recordDuration; // ✅ store for preview
      });
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _recordTimer?.cancel();
    socketService.dispose();
    _messageController.dispose();
    recorderController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryCOlor,
      key: _scaffoldKey,
      endDrawer: SideMenuDrawer(
        crossOnTap: () => _scaffoldKey.currentState?.closeEndDrawer(),
        isTutor: globalUserRole == "TUTOR" ? true : false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20, top: 50, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo1.png', height: 50),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                      child: _roundIcon("assets/images/menu.png",
                          iconColor: AppTheme.primaryCOlor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: ScreenSize(context).width,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  _chatHeader(),
                  if (!socketService.isConnected || !_isRoomJoined)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Connecting...',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                          loadChatHistory();
                        }
                        return true;
                      },
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final current = messages[index];
                          final previous = index < messages.length - 1
                              ? messages[index + 1]
                              : null;
                          final next = index > 0 ? messages[index - 1] : null;
                          final showAvatar = !current.isMe &&
                              (previous == null ||
                                  previous.isMe != current.isMe);

                          bool showTime = true;
                          if (next != null) {
                            final sameSender = next.isMe == current.isMe;
                            final sameMinute =
                                _isSameMinute(next.time, current.time);

                            if (sameSender && sameMinute) {
                              showTime = false;
                            }
                          }

                          return GestureDetector(
                            onLongPress: () {
                              if (current.isMe == true &&
                                  current.text != "This message was deleted") {
                                _showDeleteOptions(current);
                              }
                            },
                            child: ChatBubble(
                              image: widget.image,
                              message: messages[index],
                              showAvatar: showAvatar,
                              showTime: showTime,
                              onStatusChange: (
                                messageId,
                                newStatus,
                              ) async {
                                if (newStatus == "ACCEPTED") {
                                  final msgIndex = messages
                                      .indexWhere((m) => m.id == messageId);
                                  if (msgIndex == -1 ||
                                      messages[msgIndex].offer == null) return;
                                  final offerId =
                                      messages[msgIndex].offer!["id"];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ParentCardScreen(offerId: offerId),
                                    ),
                                  ).then((_) => _refreshChatAfterPayment());
                                } else if (newStatus == "REJECTED") {
                                  updateOfferStatus(
                                      context, messageId, newStatus);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (_previewMessage != null) _mediaPreview(_previewMessage!),
                  if (isRecording) _recordingBar(),
                  if (_previewAudio != null) _audioPreviewBar(),
                  if (!isRecording &&
                      _previewAudio == null &&
                      _previewMessage == null)
                    _inputBar(),
                  _chatOptionsPanel(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showDeleteOptions(ChatMessage message) {
    final now = DateTime.now();
    final diff = now.difference(message.createdAt);
    final canDeleteForEveryone = diff.inSeconds <= 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _deleteTile(
                icon: Icons.delete_forever,
                color: canDeleteForEveryone ? Colors.red : Colors.grey,
                title: "Delete for everyone",
                subtitle: canDeleteForEveryone
                    ? null
                    : "You can delete only within 1 minute",
                onTap: canDeleteForEveryone
                    ? () {
                        Navigator.pop(context);
                        _deleteMessage(message); // 👈 socket delete
                      }
                    : null,
              ),
              const Divider(),
              _deleteTile(
                icon: Icons.close,
                color: Colors.black,
                title: "Cancel",
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _deleteTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color color = Colors.black,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      enabled: onTap != null,
      onTap: onTap,
    );
  }

  void _refreshChatAfterPayment() {
    setState(() {
      messages.clear();
      page = 1;
      hasMore = true;
    });

    loadChatHistory(); // 👈 tumhari existing API call
  }

  bool _isSameMinute(String t1, String t2) {
    try {
      final f = DateFormat('h:mm a');
      final d1 = f.parse(t1);
      final d2 = f.parse(t2);

      return d1.hour == d2.hour && d1.minute == d2.minute;
    } catch (_) {
      return false;
    }
  }

  Widget _audioPreviewBar() {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryCOlor),
      ),
      child: Row(
        children: [
          Expanded(
            child: AudioBubblePlayer(
              url: _previewAudio!.path,
              isLocal: true,
              isSendSide: true,
              initialDuration: _recordDuration,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => setState(() => _previewAudio = null),
          ),
          IconButton(
            icon: Icon(Icons.send, color: AppTheme.primaryCOlor),
            onPressed: () {
              _sendMedia(
                file: _previewAudio!.path,
                type: "AUDIO",
                duration: _previewAudioDuration,
              );
              setState(() => _previewAudio = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(String asset, {Color? iconColor}) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.asset(asset, color: iconColor),
      ),
    );
  }

  Widget _chatHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: GestureDetector(
        onTap: () {
          if (globalUserRole == "PARENT") {
            push(
                context,
                TutorProfileScreen(
                  isParentSide: true,
                  tutorId: widget.recieverId,
                  name: widget.recieverName,
                  isFromChat: true,
                ));
          } else {
            push(
                context,
                ParentProfileScreen(
                  isTutorSide: true,
                  parentId: widget.recieverId,
                ));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: [
              Color.fromARGB(255, 141, 192, 177),
              Color(0xff4BB698),
              Color.fromARGB(255, 35, 165, 209),
              Color.fromARGB(255, 43, 145, 180),
              Color(0xff1D83A5),
            ]),
          ),
          child: Row(
            children: [
              Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: widget.image == "" || widget.image.isEmpty
                      ? ClipOval(
                          child: Image.asset(globalUserRole == 'TUTOR'
                              ? "assets/images/parentProfile.jpeg"
                              : "assets/images/tutorProfile.jpeg"))
                      : widget.image.startsWith('http')
                          ? ClipOval(
                              child: Image.network(
                                widget.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(globalUserRole == 'TUTOR'
                                      ? "assets/images/parentProfile.jpeg"
                                      : "assets/images/tutorProfile.jpeg");
                                },
                              ),
                            )
                          : ClipOval(
                              child:
                                  Base64ImageWidget(base64String: widget.image),
                            )),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.appText("${widget.recieverName}",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      textColor: Colors.white),
                  // AppText.appText("Connected Since 2 months",
                  //     fontSize: 12, textColor: Colors.white70),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.borderCOlor))),
      child: Row(
        children: [
          if (_messageController.text.trim().isEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  FocusScope.of(context).unfocus();
                  _showOptions = !_showOptions;
                  if (_showOptions == true) {
                    FocusScope.of(context).unfocus();
                  }
                });
              },
              child: Icon(
                  _showOptions == true
                      ? Icons.highlight_remove_sharp
                      : Icons.add_circle_outline,
                  size: 28,
                  color: AppTheme.primaryCOlor),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomAppTextField(
              texthint: "Write your message",
              hintStyle: const TextStyle(color: Colors.grey),
              controller: _messageController,
              onTap: () {
                if (_showOptions) {
                  setState(() {
                    _showOptions =
                        false; // hide options when user taps text field
                  });
                }
              },
              onChanged: (val) {
                if (val.isNotEmpty && _showOptions) {
                  setState(() {
                    _showOptions = false;
                  });
                } else {
                  setState(() {});
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          _messageController.text.trim().isEmpty
              ? GestureDetector(
                  onTap: startRecording,
                  child: Image.asset("assets/images/mic.png",
                      height: 20, color: AppTheme.primaryCOlor),
                )
              : GestureDetector(
                  onTap: () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) sendMessage(text);
                  },
                  child: Icon(Icons.send, color: AppTheme.primaryCOlor),
                ),
        ],
      ),
    );
  }

  Widget _chatOptionsPanel() {
    if (!_showOptions) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              if (globalUserRole == "TUTOR")
                _optionButton(Icons.note_add, "Create an offer", () {
                  CustomOfferSheet.show(
                    context,
                    widget.conversationId,
                    childrensData,
                    widget.userId,
                    widget.recieverId,
                    socketService,
                    (newMessage) {
                      // This is the callback
                      setState(() {
                        messages.insert(0, newMessage);
                      });
                    },
                  );
                }),
              SizedBox(width: 10),
              _optionButton(Icons.attach_file, "Send a file", () {
                _showOptions = false;
                _pickFile();
              }),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _optionButton(Icons.photo, "Photo album", () {
                _showOptions = false;
                _pickImageFromGallery();
              }),
              SizedBox(width: 10),
              _optionButton(Icons.camera_alt, "Open Camera", () {
                _showOptions = false;
                _openCamera();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _optionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: AppTheme.primaryCOlor),
              SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  /////////////////////////// Files /////////////////////////////////////////////
  Widget _recordingBar() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_recordDuration ~/ 60);
    final seconds = twoDigits(_recordDuration % 60);

    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryCOlor),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/mic.png",
              height: 24, color: AppTheme.primaryCOlor),
          const SizedBox(width: 10),
          // 👇 Waveform bar
          AudioWaveforms(
            enableGesture: false,
            size: Size(MediaQuery.of(context).size.width * 0.40, 50.0),
            recorderController: recorderController,
            waveStyle: const WaveStyle(
              waveColor: Colors.blue,
              extendWaveform: true,
              showMiddleLine: false,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "$minutes:$seconds",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => stopRecording(cancelled: true),
          ),

          CircleIconButton(
            onTap: () {
              stopRecording();
            },
            assetPath: "assets/images/ok.png",
            iconColor: AppTheme.primaryCOlor,
            backgroundColor: Colors.transparent,
            borderColor: AppTheme.primaryCOlor,
            size: 25,
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        _previewMessage = ChatMessage(
          id: "temp-file",
          text: result.files.single.name,
          type: "FILE",
          isMe: true,
          isPending: true,
          filePath: result.files.single.path!,
          createdAt: DateTime.now(),
          time: _formatTime(DateTime.now().toIso8601String()),
        );
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
        _previewMessage = ChatMessage(
          id: "temp-image",
          text: "Image selected",
          createdAt: DateTime.now(),
          type: "IMAGE",
          isMe: true,
          isPending: true,
          filePath: pickedFile.path,
          time: _formatTime(DateTime.now().toIso8601String()),
        );
      });
    }
  }

  Future<void> _openCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
        _previewMessage = ChatMessage(
          id: "temp-image",
          text: "Camera Image",
          type: "IMAGE",
          createdAt: DateTime.now(),
          isMe: true,
          isPending: true,
          filePath: pickedFile.path,
          time: _formatTime(DateTime.now().toIso8601String()),
        );
      });
    }
  }
  ///////////////////////////////////////   API HITING ?????????????????????????????????

  Future<void> updateOfferStatus(
    context,
    String messageId,
    String newStatus,
  ) async {
    try {
      // find the message by id so we can get offerId
      final msgIndex = messages.indexWhere((m) => m.id == messageId);
      if (msgIndex == -1 || messages[msgIndex].offer == null) return;
      final offerId = messages[msgIndex].offer!["id"];

      debugPrint(
          "Message ID: $messageId     status:  $newStatus    offerId $offerId");

      final response = await dio.patch(
        path: "${AppUrls.offerStatus}$newStatus/$offerId",
      );
      var responseData = response.data;
      if (response.statusCode == 200) {
        setState(() {
          final oldMsg = messages[msgIndex];
          final updatedOffer = Map<String, dynamic>.from(oldMsg.offer ?? {});
          updatedOffer["status"] = newStatus;

          messages[msgIndex] = oldMsg.copyWith(offer: updatedOffer);
          if (newStatus == "ACCEPTED") {
            AppToast.success(
              context: context,
              msg: "Payment Successful. Session has been registered!",
            );
          }
        });
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
            context: context, msg: "${responseData["errors"][0]["message"]}");
        handleTokenExpiration();
      } else {
        AppToast.error(
            context: context, msg: "${responseData["errors"][0]["message"]}");
      }
    } catch (e) {
      debugPrint("Error updating offer status: $e");
    }
  }

//////////////////////////////  Send Media Messages ////////////////////////////////////

  Widget _mediaPreview(ChatMessage message) {
    print("here is the message ${message.text}  type: ${message.type}");
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryCOlor),
      ),
      child: Row(
        children: [
          if (message.type == "IMAGE")
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(message.filePath!),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )
          else
            Icon(Icons.insert_drive_file,
                size: 40, color: AppTheme.primaryCOlor),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message.type == "IMAGE" ? "Image selected" : message.text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => setState(() => _previewMessage = null),
          ),
          IconButton(
            icon: Icon(Icons.send, color: AppTheme.primaryCOlor),
            onPressed: () {
              _sendMedia(
                  file: message.filePath,
                  type: message.type == "IMAGE" ? 'IMAGE' : "FILE");
              setState(() => _previewMessage = null);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMedia({file, required String type, int? duration}) async {
    final tempId = "temp-${DateTime.now().millisecondsSinceEpoch}";

    setState(() {
      messages.insert(
        0,
        ChatMessage(
          id: tempId,
          text: "Sending file...",
          fileText: "Sending file.....",
          type: type,
          createdAt: DateTime.now(),
          time: _formatTime(DateTime.now().toIso8601String()),
          isMe: true,
          isPending: true,
          audioDuration: duration,
          filePath: file,
        ),
      );
    });

    final uploadResponse = await _uploadMedia(
      file: file,
      type: type,
      duration: type == "AUDIO" ? _previewAudioDuration : null,
    );

    if (uploadResponse == null) {
      debugPrint("❌ Upload failed");
      return;
    }

    final fileId = uploadResponse["data"]["id"];
    final filename = uploadResponse["data"]["originalName"];
    final fileUrl = uploadResponse["data"]["metadata"]["absolutePath"];
    final recordTime = uploadResponse["data"]["metadata"]["duration"];

    final message = {
      "conversationId": widget.conversationId,
      "fileId": fileId,
      "content": fileUrl,
      "type": type,
    };

    socketService.sendMessage(message);

    final index = messages.indexWhere((m) => m.id == tempId);
    if (index != -1) {
      if (type == "AUDIO") {
        setState(() {
          messages[index] = messages[index].copyWith(
            id: fileId,
            isPending: false,
            text: fileUrl,
            fileText: filename,
            audioDuration: int.tryParse(recordTime) ?? 0,
          );
        });
      } else {
        setState(() {
          messages[index] = messages[index].copyWith(
            id: fileId,
            isPending: false,
            text: fileUrl,
            fileText: filename,
          );
        });
      }

      _playSendSound();
    }
  }

  Future<Map<String, dynamic>?> _uploadMedia({
    required String file,
    required String type,
    int? duration,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        "conversationId": widget.conversationId,
        "file": await MultipartFile.fromFile(file),
      };

      // ✅ ONLY for AUDIO
      if (type == "AUDIO" && duration != null) {
        formMap["duration"] =
            duration; // or "${duration}s" if backend wants string
      }

      final formData = FormData.fromMap(formMap);
      debugPrint("📦 ===== FORM DATA DEBUG =====");

      for (var field in formData.fields) {
        debugPrint("FIELD ➜ ${field.key}: ${field.value}");
      }

      for (var file in formData.files) {
        debugPrint("FILE ➜ ${file.key}: ${file.value.filename}");
      }

      debugPrint("📦 ==========================");

      final response = await dio.post(
        path: AppUrls.sendMedia,
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint("❌ Upload error: $e");
    }
    return null;
  }
}
