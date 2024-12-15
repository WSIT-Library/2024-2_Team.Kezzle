import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kezzle/models/home_store_model.dart';
import 'package:kezzle/repo/curation_repo.dart';
import 'package:kezzle/widgets/cake_with_keyword_widget.dart';

class InfiniteCurationScreen extends ConsumerStatefulWidget {
  static const routeName = '/infinite_curation_screen';
  static const routeUrl = '/infinite_curation_screen';
  final String curationId;
  final String curationDescription;

  const InfiniteCurationScreen(
      {super.key, required this.curationId, required this.curationDescription})
      ;

  @override
  ConsumerState<InfiniteCurationScreen> createState() =>
      _InfiniteCurationScreenState();
}

class _InfiniteCurationScreenState
    extends ConsumerState<InfiniteCurationScreen> {
  // List<String> items = List.generate(15, (index) => 'Item ${index + 1}');
  // List<String> items = [];
  List<Cake> items = [];
  final controller = ScrollController();
  int page = 0;
  bool hasMore = true;
  bool isLoading = false;
  final List<double> widthList = [240, 174, 200, 174];

  Future refresh() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      page = 0;
      items.clear();
    });

    fetch();

    // api 요청
    // await Future.delayed(const Duration(seconds: 1));
    // //api 요청 결과로 리스트 업데이트
    // setState(() {
    //   List<String> items = List.generate(15, (index) => 'Item ${index + 1}');
    //   this.items.addAll(items);
    // });
  }

  @override
  void initState() {
    super.initState();

    fetch();

    controller.addListener(() {
      if (controller.offset > controller.position.maxScrollExtent - 300 &&
          hasMore) {
        fetch();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future fetch() async {
    if (isLoading) return;

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    // limit 잘 제한하기
    const limit = 20;
    // limit, page로 api 요청
    // api 요청해서 받아오기
    // await Future.delayed(const Duration(seconds: 2));

    List<Cake> newItems = [];
    final response = await ref
        .read(curationRepo)
        .fetchCurationCakesById(curationId: widget.curationId, page: page);
    response['cakes'].forEach((cake) {
      newItems.add(Cake.fromJson(cake));
    });

    if (mounted) {
      setState(() {
        page++;
        isLoading = false;
        if (newItems.length < limit) {
          hasMore = false;
        }
        items.addAll(newItems);
      });
    }

    // final List<String> newItems =
    //     List.generate(15, (index) => 'Item ${index + 1}');

    // setState(() {
    //   page++;
    //   // isLoading = false;

    //   if (newItems.length < limit) {
    //     hasMore = false;
    //   }
    //   items.addAll(newItems);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.curationDescription
                .replaceAll(RegExp('\n'), ' ')
                .replaceAll(RegExp('  '), ' '))),
        body: items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: CustomScrollView(
                  // physics: AlwaysScrollableScrollPhysics(),
                  controller: controller,
                  slivers: [
                    SliverMasonryGrid(
                      mainAxisSpacing: 23,
                      crossAxisSpacing: 5,
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return CakeKeywordWidget(
                            width: widthList[index % 4],
                            cake: items[index],
                          );
                        },
                        childCount: items.length,
                      ),
                      gridDelegate:
                          const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                    ),
                    if (isLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator())),
                      ),
                  ],
                ),
              ));
  }
}
