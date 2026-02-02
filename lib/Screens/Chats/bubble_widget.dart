import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/base_image.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Chats/chat_modet.dart';
import 'package:ustaad/Screens/Chats/image_view_screen.dart';
import 'package:ustaad/config/keys/global.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String image;
  final bool showTime;

  final bool showAvatar;

  final Function(String messageId, String newStatus)? onStatusChange;
  const ChatBubble({
    super.key,
    required this.message,
    this.onStatusChange,
    required this.image,
    required this.showAvatar,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (showAvatar) ...[
            _avatar(),
            const SizedBox(width: 8),
          ] else if (!message.isMe) ...[
            const SizedBox(width: 50),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageByType(context),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMessageByType(BuildContext context) {
    final alignment =
        message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    if (message.type == "TEXT") {
      return _buildTextMessage(context, alignment);
    } else if (message.type == "IMAGE") {
      return _buildImageMessage(context, alignment, message.text);
    } else if (message.type == "FILE") {
      return FileBubble(
        url: message.text,
        isMe: message.isMe,
        name: message.fileText!,
        time: message.time,
        showStatusIcon: message.isMe,
        isPending: message.isPending,
      );
    } else if (message.type == "AUDIO") {
      return _buildAudioMessage(context, alignment, message.text);
    } else {
      return _buildOfferMessage(context, alignment);
    }
  }

  Widget _avatar() {
    return Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: image == "" || image.isEmpty
            ? ClipOval(
                child: Image.asset(globalUserRole == 'TUTOR'
                    ? 'assets/images/parentProfile.jpeg'
                    : "assets/images/tutorProfile.jpeg"))
            : image.startsWith('http')
                ? ClipOval(
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(globalUserRole == 'TUTOR'
                            ? 'assets/images/parentProfile.jpeg'
                            : "assets/images/tutorProfile.jpeg");
                      },
                    ),
                  )
                : ClipOval(
                    child: Base64ImageWidget(base64String: image),
                  ));
  }

  // Widget _buildDynamicMessage(
  //     BuildContext context, CrossAxisAlignment alignment) {
  //   final text = message.text.toLowerCase();

  //   if (_isImage(text)) {
  //     return _buildImageMessage(context, alignment, message.text);
  //   } else if (_isFile(text)) {
  //     return FileBubble(
  //       url: message.text,
  //       isMe: message.isMe,
  //       time: message.time,
  //       showStatusIcon: message.isMe,
  //       isPending: message.isPending,
  //     );
  //   } else {
  //   }
  // }

  Widget _buildAudioMessage(
      BuildContext context, CrossAxisAlignment alignment, String url) {
    final audioUrl = "http://15.235.204.49:305/$url";

    print("here is the timing of the voice recrd : ${message.audioDuration}");

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          height: 38,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: message.isMe ? AppTheme.primaryCOlor : Color(0xffF2F7FB),
            borderRadius: _bubbleRadius(message.isMe),
          ),
          child: Row(
            children: [
              Expanded(
                child: AudioBubblePlayer(
                  key: ValueKey(message.id),
                  url: audioUrl,
                  isMe: message.isMe,
                  isLocal: false,
                  isSendSide: false,
                  initialDuration: message.audioDuration,
                ),
              ),
              if (message.isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Icon(
                    message.isPending ? Icons.access_time : Icons.done_all,
                    size: 14,
                    color: message.isPending ? Colors.grey : Colors.white,
                  ),
                ),
            ],
          ),
        ),
        _timeStamp(),
      ],
    );
  }

  Widget _buildImageMessage(
      BuildContext context, CrossAxisAlignment alignment, String url) {
    final fullUrl = "http://15.235.204.49:305/$url";
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImageViewScreen(imageUrl: fullUrl),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 4),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  borderRadius: _bubbleRadius(message.isMe),
                  border: Border.all(
                      color: message.isMe
                          ? AppTheme.primaryCOlor
                          : Color(0xffF2F7FB),
                      width: 2),
                ),
                child: ClipRRect(
                  borderRadius: message.isMe
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        )
                      : const BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                  child: CachedNetworkImage(
                    imageUrl: fullUrl,
                    fit: BoxFit.fill,
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      final progress = downloadProgress.progress ?? 0;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(color: Colors.grey.shade200),
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue),
                          ),
                          Text(
                            "${(progress * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      );
                    },
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.red, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (message.isMe)
              Positioned(
                bottom: 8,
                right: 8,
                child: Icon(
                  message.isPending ? Icons.access_time : Icons.done_all,
                  size: 16,
                  color:
                      message.isPending ? Colors.grey : AppTheme.primaryCOlor,
                ),
              ),
          ],
        ),
        _timeStamp(),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget _buildTextMessage(BuildContext context, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        _bubbleContainer(
          context,
          message.text,
          "TEXT",
          isMe: message.isMe,
          showStatusIcon: message.isMe,
          isPending: message.isPending,
        ),
        _timeStamp(),
      ],
    );
  }

  Widget _buildOfferMessage(
      BuildContext context, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        _offerContainer(context, message.isMe),
        _bubbleContainer(
          context,
          message.text,
          "OFFER",
          isMe: message.isMe,
          showStatusIcon: message.isMe,
          isPending: message.isPending,
        ),
        _timeStamp(),
      ],
    );
  }

  Widget _offerContainer(BuildContext context, isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        borderRadius: _bubbleRadius(message.isMe),
        border: Border.all(
            color: isMe ? AppTheme.primaryCOlor : Color(0xffF2F7FB), width: 2),
      ),
      child: Column(
        children: [
          _offerHeader(isMe: isMe),
          const SizedBox(height: 10),
          _offerText("Description", message.offer!["description"]),
          const SizedBox(height: 10),
          _offerRow(
              "Student Name", capitalizeEachWord(message.offer!["childName"])),
          const SizedBox(height: 10),
          _offerRow(
            "Subjects",
            (message.offer!["subject"] as List)
                .map((s) => capitalizeEachWord(s.toString()))
                .join(", "),
          ),
          const SizedBox(height: 10),
          _offerRow("Sessions", "${message.offer!["sessions"]}"),
          const SizedBox(height: 10),
          _offerRow("Offer Price", "RS.${message.offer!["amountMonthly"]}"),
          const SizedBox(height: 10),
          _offerRow("Starting Date", message.offer!["startDate"]),
          const SizedBox(height: 10),
          _offerRow(
            "Session Time",
            "${formatTime(message.offer!["startTime"])} - ${formatTime(message.offer!["endTime"])}",
          ),
          const SizedBox(height: 10),
          _offerRow(
            "Days of Week",
            formatDays(message.offer!["daysOfWeek"]),
          ),
          const SizedBox(height: 20),
          _offerActions(context),
        ],
      ),
    );
  }

  Widget _offerHeader({isMe}) {
    return Container(
      height: 40,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isMe ? AppTheme.primaryCOlor : Color(0xffF2F7FB),
      ),
      child: Center(
        child: AppText.appText(
          "Offer",
          textColor: isMe ? AppTheme.white : AppTheme.black,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _offerText(String title, String value) {
    return AppText.appText(
      value,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
  }

  Widget _offerRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.appText(
          "$title: ",
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        Expanded(
          child: AppText.appText(
            value,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            maxlines: null,
          ),
        ),
      ],
    );
  }

  Widget _offerActions(BuildContext context) {
    if (message.isMe) {
      return AppButton.appButton(
        "${message.offer!["status"]}",
        context: context,
        backgroundColor: "${message.offer!["status"]}" == "ACCEPTED"
            ? AppTheme.appColor
            : "${message.offer!["status"]}" == "PENDING"
                ? AppTheme.borderCOlor
                : Colors.red,
        border: false,
      );
    }

    if (message.offer!["status"] == "PENDING" && message.isMe != true) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton.appButton(
            "Accept",
            context: context,
            width: ScreenSize(context).width * 0.22,
            onTap: () {
              if (onStatusChange != null) {
                onStatusChange!(message.id, "ACCEPTED");
              }
            },
            backgroundColor: AppTheme.appColor,
            border: false,
          ),
          const SizedBox(width: 20),
          AppButton.appButton(
            "Reject",
            width: ScreenSize(context).width * 0.22,
            onTap: () {
              if (onStatusChange != null) {
                onStatusChange!(message.id, "REJECTED");
              }
            },
            context: context,
            backgroundColor: Colors.red,
            border: false,
          ),
        ],
      );
    }

    return AppButton.appButton(
      "${message.offer!["status"]}",
      context: context,
      backgroundColor: "${message.offer!["status"]}" == "ACCEPTED"
          ? AppTheme.appColor
          : Colors.red,
      border: false,
    );
  }

  Widget _bubbleContainer(
    BuildContext context,
    String text,
    String type, {
    required bool isMe,
    bool showStatusIcon = false,
    bool isPending = false,
  }) {
    final bgColor = isMe ? AppTheme.primaryCOlor : Color(0xffF2F7FB);
    final textColor = isMe ? Colors.white : AppTheme.black;
    print("here is the message of the ofer ${text}");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: _bubbleRadius(isMe),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: AppText.appText(
              type == "OFFER" ? formatOfferMessage(text) : text,
              textColor: text == 'This message was deleted'
                  ? isMe
                      ? const Color.fromARGB(255, 230, 228, 228)
                      : AppTheme.grey
                  : textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontStyle: text == 'This message was deleted'
                  ? FontStyle.italic
                  : FontStyle.normal,
              overflow: TextOverflow.visible,
            ),
          ),
          if (showStatusIcon)
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Icon(
                isPending ? Icons.access_time : Icons.done_all,
                size: 14,
                color: isPending ? Colors.grey : Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  String formatOfferMessage(String text) {
    if (text.isEmpty) return text;

    // Split before and after colon
    final parts = text.split(':');
    if (parts.length < 2) return text;

    // ----- Name part -----
    final titlePart = parts.first; // Offer for usama shoaib
    final name = titlePart.replaceFirst('Offer for', '').trim();

    final formattedName = name
        .split(' ')
        .map((e) => e.isNotEmpty
            ? e[0].toUpperCase() + e.substring(1).toLowerCase()
            : e)
        .join(' ');

    // ----- Subjects part -----
    final subjectsRaw =
        parts.last.replaceAll('[', '').replaceAll(']', '').trim();

    final formattedSubjects = subjectsRaw
        .split(',')
        .map((subject) => subject
            .trim()
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : word)
            .join(' '))
        .join(', ');

    return 'Offer for $formattedName: $formattedSubjects';
  }

  Widget _timeStamp() {
    if (!showTime) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: AppText.appText(
        message.time,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        textColor: Colors.grey,
      ),
    );
  }

  BorderRadius _bubbleRadius(bool isMe) {
    return isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          );
  }

  // bool _isImage(String text) {
  //   return text.endsWith(".jpg") ||
  //       text.endsWith(".jpeg") ||
  //       text.endsWith(".png") ||
  //       text.endsWith(".gif") ||
  //       text.endsWith(".webp");
  // }

  // bool _isFile(String text) {
  //   return text.endsWith(".pdf") ||
  //       text.endsWith(".doc") ||
  //       text.endsWith(".docx") ||
  //       text.endsWith(".txt") ||
  //       text.endsWith(".xls") ||
  //       text.endsWith(".xlsx");
  // }

  // bool _isAudio(String text) {
  //   return text.endsWith(".mp3") ||
  //       text.endsWith(".m4a") ||
  //       text.endsWith(".aac") ||
  //       text.endsWith(".wav");
  // }
}

String formatTime(String time) {
  final parsedTime = DateFormat("HH:mm").parse(time);
  return DateFormat("HH:mm").format(parsedTime);
}

String formatDays(List<dynamic> days) {
  return days
      .map((day) =>
          day.toString().substring(0, 1).toUpperCase() +
          day.toString().substring(1))
      .join(", ");
}

class FileBubble extends StatefulWidget {
  final String url;
  final String name;
  final bool isMe;
  final String time;
  final bool showStatusIcon;
  final bool isPending;
  const FileBubble({
    super.key,
    required this.url,
    required this.isMe,
    required this.time,
    required this.showStatusIcon,
    required this.isPending,
    required this.name,
  });

  @override
  State<FileBubble> createState() => _FileBubbleState();
}

class _FileBubbleState extends State<FileBubble> {
  bool isDownloading = false;
  double progress = 0.0;
  bool isDownloaded = false;
  String? localPath;

  Future<void> downloadFile() async {
    final fileName = widget.url.split('/').last;
    final fileUrl = "http://15.235.204.49:305/$fileName";
    final name = widget.name;

    try {
      setState(() {
        isDownloading = true;
        progress = 0.0;
      });

      final dir =
          Directory.systemTemp; // or use path_provider for persistent dir
      final savePath = "${dir.path}/$name";

      await Dio().download(
        fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = received / total;
            });
          }
        },
      );

      setState(() {
        isDownloading = false;
        isDownloaded = true;
        localPath = savePath;
        openFile();
      });
    } catch (e) {
      setState(() => isDownloading = false);
      debugPrint("Download error: $e");
    }
  }

  Future<void> openFile() async {
    if (localPath != null) {
      await OpenFilex.open(localPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.name;

    return Column(
      crossAxisAlignment:
          widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: widget.isMe ? AppTheme.primaryCOlor : Color(0xffF2F7FB),
            borderRadius: widget.isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  )
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.insert_drive_file,
                      color: widget.isMe ? Colors.white : AppTheme.black),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      fileName,
                      style: TextStyle(
                          color: widget.isMe ? Colors.white : AppTheme.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.visible),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Spacer(),
                  if (isDownloading)
                    Expanded(child: LinearProgressIndicator(value: progress)),
                  if (!isDownloading)
                    Align(
                      alignment: Alignment.center,
                      child: AppButton.appButton(
                        context: context,
                        "Open",
                        height: 35,
                        width: 70,
                        textColor: AppTheme.primaryCOlor,
                        backgroundColor: AppTheme.white,
                        onTap: () {
                          downloadFile();
                        },
                      ),
                    ),
                  Spacer(),
                  if (widget.showStatusIcon)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Icon(
                          widget.isPending ? Icons.access_time : Icons.done_all,
                          size: 14,
                          color: widget.isPending ? Colors.grey : Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Text(widget.time,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class AudioBubblePlayer extends StatefulWidget {
  final String url; // local path or remote url
  final bool isLocal;
  final bool isMe;
  final bool isSendSide;
  final int? initialDuration;

  const AudioBubblePlayer({
    super.key,
    required this.url,
    this.isLocal = false,
    this.initialDuration,
    this.isMe = false,
    required this.isSendSide,
  });

  @override
  State<AudioBubblePlayer> createState() => _AudioBubblePlayerState();
}

class _AudioBubblePlayerState extends State<AudioBubblePlayer> {
  final AudioPlayer _player = AudioPlayer();

  bool isPlaying = false;
  bool isLoading = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  late final StreamSubscription _durationSub;
  late final StreamSubscription _positionSub;
  late final StreamSubscription _stateSub;
  late final StreamSubscription _completeSub;

  @override
  void initState() {
    super.initState();

    _durationSub = _player.onDurationChanged.listen((d) {
      if (widget.initialDuration == null && mounted) {
        setState(() => duration = d);
      }
    });
    _positionSub = _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => position = p);
    });
    if (widget.initialDuration != null) {
      duration = Duration(seconds: widget.initialDuration!);
    }
    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (state == PlayerState.playing ||
            state == PlayerState.paused ||
            state == PlayerState.stopped ||
            state == PlayerState.completed) {
          isLoading = false;
        }
      });
    });

    _completeSub = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  Future<void> _togglePlay() async {
    if (isPlaying) {
      await _player.pause();
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.isLocal) {
        await _player.play(DeviceFileSource(widget.url));
      } else {
        final sanitized =
            Uri.parse(widget.url.replaceAll('\\', '/').trim()).toString();
        await _player.play(UrlSource(sanitized));
      }
    } catch (e) {
      debugPrint('❌ Audio play error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play audio')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _durationSub.cancel();
    _positionSub.cancel();
    _stateSub.cancel();
    _completeSub.cancel();
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isMe ? Colors.white : AppTheme.black;

    final maxSeconds = max(1, duration.inSeconds);
    final currentSeconds = position.inSeconds.clamp(0, maxSeconds);

    return Row(
      children: [
        if (isLoading)
          const SizedBox(
            width: 13,
            height: 13,
            child: GifLoader(),
          )
        else
          InkWell(
            onTap: _togglePlay,
            child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        widget.isMe ? AppTheme.white : AppTheme.primaryCOlor),
                child: Padding(
                  padding: isPlaying
                      ? EdgeInsets.only(
                          left: 4.33, top: 5.0, right: 5.0, bottom: 4.33)
                      : EdgeInsets.only(
                          left: 7.0, top: 4.33, right: 3.33, bottom: 4.33),
                  child: Image.asset(
                    isPlaying
                        ? "assets/images/pause.png"
                        : "assets/images/play.png",
                    color:
                        widget.isMe ? AppTheme.primaryCOlor : Color(0xffF2F7FB),
                  ),
                )),
          ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 15,
              ),
            ),
            child: Slider(
              activeColor: textColor,
              inactiveColor: Colors.grey.shade400,
              value: currentSeconds.toDouble(),
              max: maxSeconds.toDouble(),
              onChanged: (value) async {
                final to = Duration(seconds: value.toInt());
                await _player.seek(to);
              },
            ),
          ),
        ),
        Text(
          isPlaying ? _format(position) : _format(duration),
          style: TextStyle(
            color: widget.isSendSide
                ? Colors.black
                : widget.isMe
                    ? Colors.white
                    : AppTheme.black,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
