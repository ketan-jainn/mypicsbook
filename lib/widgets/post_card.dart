import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/models/user.dart' as model;
import 'package:instagram_clone_flutter/providers/user_provider.dart';
import 'package:instagram_clone_flutter/resources/firestore_methods.dart';
import 'package:instagram_clone_flutter/screens/comments_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/global_variable.dart';
import 'package:instagram_clone_flutter/utils/utils.dart';
import 'package:instagram_clone_flutter/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  final String uid;
  const PostCard({
    Key? key,
    required this.snap,
    required this.uid,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.AppUser? user = context.watch<UserProvider>().getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xff222228),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Column(
            children: [
              // HEADER SECTION OF THE POST
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        widget.snap['profImage'].toString(),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.snap['username'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.snap['uid'] == user?.uid
                        ? IconButton(
                            onPressed: () {
                              showDialog(
                                useRootNavigator: false,
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: ListView(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shrinkWrap: true,
                                        children: [
                                          'Delete',
                                        ]
                                            .map(
                                              (e) => InkWell(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                    child: Text(e),
                                                  ),
                                                  onTap: () {
                                                    deletePost(
                                                      widget.snap['postId']
                                                          .toString(),
                                                    );
                                                    // remove the dialog box
                                                    Navigator.of(context).pop();
                                                  }),
                                            )
                                            .toList()),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.more_vert),
                          )
                        : Container(),
                  ],
                ),
              ),
              // IMAGE SECTION OF THE POST
              GestureDetector(
                onDoubleTap: () {
                  FireStoreMethods().likePost(
                    widget.snap['postId'].toString(),
                    user!.uid,
                    widget.snap['likes'],
                  );
                  setState(() {
                    isLikeAnimating = true;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.snap['postUrl'].toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLikeAnimating ? 1 : 0,
                      child: LikeAnimation(
                        isAnimating: isLikeAnimating,
                        duration: const Duration(
                          milliseconds: 400,
                        ),
                        onEnd: () {
                          setState(() {
                            isLikeAnimating = false;
                          });
                        },
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // LIKE, COMMENT SECTION OF THE POST
              Row(
                children: <Widget>[
                  LikeAnimation(
                    isAnimating: widget.snap['likes'].contains(widget.uid),
                    smallLike: true,
                    child: IconButton(
                      icon: widget.snap['likes'].contains(user!.uid)
                          ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.favorite_border,
                            ),
                      onPressed: () => FireStoreMethods().likePost(
                        widget.snap['postId'].toString(),
                        user.uid,
                        widget.snap['likes'],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.comment_outlined,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                          postId: widget.snap['postId'].toString(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //DESCRIPTION AND NUMBER OF COMMENTS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DefaultTextStyle(
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(fontWeight: FontWeight.w800),
                        child: Text(
                          '${widget.snap['likes'].length} likes',
                          style: Theme.of(context).textTheme.bodyText2,
                        )),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: primaryColor),
                          children: [
                            TextSpan(
                              text: widget.snap['username'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' ${widget.snap['description']}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'View all $commentLen comments',
                          style: const TextStyle(
                            fontSize: 16,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            postId: widget.snap['postId'].toString(),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        DateFormat.yMMMd()
                            .format(widget.snap['datePublished'].toDate()),
                        style: const TextStyle(
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
