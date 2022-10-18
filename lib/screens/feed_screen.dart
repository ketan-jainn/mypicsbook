import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/global_variable.dart';
import 'package:instagram_clone_flutter/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              shadowColor: mobileBackgroundColor,
              surfaceTintColor: mobileBackgroundColor,
              centerTitle: true,
              elevation: 0,
              title: Text('Picsgram',
                  style: GoogleFonts.lobster(
                    fontSize: 25,
                  )),
            ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.active) {
                      Map<String, dynamic> data =
                          snapshot.data!.docs[index].data();
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: width > webScreenSize ? width * 0.3 : 0,
                          vertical: width > webScreenSize ? 15 : 0,
                        ),
                        child: PostCard(
                          snap: data,
                          uid: data['uid'],
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
