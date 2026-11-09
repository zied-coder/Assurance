import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Map<String, String>> _messages = [];
  final String sessionId = "mobile-${DateTime.now().millisecondsSinceEpoch}";
  bool _isLoading = false;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await ApiService.sendChatMessage(text, sessionId);

    if (!mounted) return;
    setState(() {
      _messages.add({"sender": "bot", "text": response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BnaScaffold(
      title: "Assistant BNA",
      watermark: false,
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _emptyState()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg["sender"] == "user";
                      return _bubble(msg["text"] ?? "", isUser);
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("L'assistant écrit…",
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic)),
              ),
            ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.forum_outlined,
                  color: Colors.white, size: 34),
            ),
            const SizedBox(height: 18),
            const Text("Comment puis-je vous aider ?",
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Posez une question sur vos contrats, sinistres ou garanties.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.primaryGradient : null,
          color: isUser ? null : AppColors.glassFill,
          border: isUser
              ? null
              : Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppColors.textPrimary),
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: "Posez votre question…",
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
