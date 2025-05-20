import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  final String movieId;
  const CommentSection({Key? key, required this.movieId}) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  void _fetchComments() async {
    await Future.delayed(const Duration(milliseconds: 500)); // giả lập API
    setState(() {
      comments = [
        'Phim rất hay!',
        'Diễn viên quá đỉnh.',
        'Nội dung hấp dẫn lắm.',
      ];
    });
  }

  void _addComment() {
    final comment = _controller.text.trim();
    if (comment.isEmpty) return;

    setState(() {
      comments.insert(0, comment);
    });

    _controller.clear();
    FocusScope.of(context).unfocus();

    // TODO: Call API để lưu comment nếu cần
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bình luận',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Viết bình luận...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Gửi'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        comments.isEmpty
            ? const Text('Chưa có bình luận nào.', style: TextStyle(color: Colors.white70))
            : ListView.separated(
                controller: _scrollController,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: comments.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.comment, color: Colors.white38),
                    title: Text(
                      comments[index],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
