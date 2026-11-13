import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../calls/presentation/pages/one_on_one_call_page.dart';
import '../../domain/entities/chat_item.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ConversationPage extends StatefulWidget {
  final ChatItem chat;

  const ConversationPage({super.key, required this.chat});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(MarkChatAsReadEvent(widget.chat.id));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDarkGreen,
      appBar: AppBar(
        title: Text(widget.chat.title, style: AppTextStyles.titleBold),
        backgroundColor: AppColors.bottomNavBg,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_rounded, color: AppColors.gemEmerald),
            tooltip: '1v1 Voice Call (120 💎/m)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OneOnOneCallPage(
                    calleeId: widget.chat.id,
                    calleeName: widget.chat.title,
                    calleeAvatar: widget.chat.avatarUrl ?? '',
                    isVideoCall: false,
                    gemsPerMinute: 120,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: AppColors.goldCoin),
            tooltip: '1v1 Video Call (240 💎/m)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OneOnOneCallPage(
                    calleeId: widget.chat.id,
                    calleeName: widget.chat.title,
                    calleeAvatar: widget.chat.avatarUrl ?? '',
                    isVideoCall: true,
                    gemsPerMinute: 240,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final messages = state.messagesMap[widget.chat.id] ?? [];
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    return Align(
                      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: msg.isMe ? AppColors.primaryGreen : Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                          ),
                          border: Border.all(
                            color: msg.isMe ? AppColors.gemEmerald.withOpacity(0.4) : Colors.white12,
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.bottomNavBg,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.black26,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.gemEmerald),
                    onPressed: () {
                      final txt = _controller.text.trim();
                      if (txt.isNotEmpty) {
                        context.read<ChatBloc>().add(
                              SendDirectMessageEvent(chatId: widget.chat.id, text: txt),
                            );
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
