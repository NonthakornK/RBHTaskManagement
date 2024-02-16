import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rbh_task_management/main.dart';
import 'package:rbh_task_management/src/core/session_handler.dart';
import 'package:rbh_task_management/src/data/response/task_list_response.dart';
import 'package:rxdart/rxdart.dart';

import 'task_list_view_model.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});
  static const routeName = '/task_list';

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with SingleTickerProviderStateMixin, SessionHandler {
  final _viewModel = getIt<TaskListViewModel>();
  final compositeSubscription = CompositeSubscription();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshTodoController = RefreshController();
  final RefreshController _refreshDoingController = RefreshController();
  final RefreshController _refreshDoneController = RefreshController();

  bool _isError = false;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _subscribeToViewModel();
    _viewModel.onPageLoad();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _refreshTodoController.dispose();
    _refreshDoingController.dispose();
    _refreshDoneController.dispose();
    compositeSubscription.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [Colors.deepPurple, Colors.deepPurpleAccent]),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      Text(
                        "To the task management application",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        "Swipe each tasks to dismiss them",
                        style: Theme.of(context).textTheme.displayMedium,
                      )
                    ],
                  )),
            ),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                titleSpacing: 0,
                title: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.grey.shade200,
                  ),
                  child: TabBar(
                      controller: _tabController,
                      splashBorderRadius: BorderRadius.circular(50),
                      tabs: const [
                        Tab(
                          child: Text("To-do"),
                        ),
                        Tab(
                          child: Text("Doing"),
                        ),
                        Tab(
                          child: Text("Done"),
                        ),
                      ]),
                ),
              ),
            )
          ],
          body: _buildTabBarView(),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildTab(
          _viewModel.todoList,
          TaskGroup.todo,
          _refreshTodoController,
        ),
        _buildTab(
          _viewModel.doingList,
          TaskGroup.doing,
          _refreshDoingController,
        ),
        _buildTab(
          _viewModel.doneList,
          TaskGroup.done,
          _refreshDoneController,
        ),
      ],
    );
  }

  Widget _buildTab(Stream<TaskListResponse> taskList, TaskGroup group,
      RefreshController controller) {
    return StreamBuilder<TaskListResponse>(
      stream: taskList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        final data = snapshot.data!;
        final tasks = data.tasks ?? [];
        final pageNumber = data.pageNumber;
        final totalPages = data.totalPages;
        final loadMore =
            pageNumber == null || totalPages == null || pageNumber < totalPages;
        if (!loadMore) controller.loadNoData();
        return SmartRefresher(
          controller: controller,
          onLoading: () async {
            final result = await _viewModel.onScrollEnd(group);
            result ? controller.loadComplete() : controller.loadFailed();
          },
          enablePullUp: true,
          enablePullDown: false,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverVisibility(
                visible: tasks.isNotEmpty,
                replacementSliver: SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.text_snippet,
                        size: 60,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Empty tasks",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Visibility(
                        visible: loadMore,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            "Scroll down to load more",
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                sliver: SliverPadding(
                  padding: const EdgeInsets.only(top: 8),
                  sliver: SliverList.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateHeader(
                              tasks[index].createdAt,
                              index == 0 ||
                                  !DateUtils.isSameDay(tasks[index].createdAt,
                                      tasks[index - 1].createdAt)),
                          Dismissible(
                            key: Key(tasks[index].id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                            ),
                            resizeDuration: const Duration(milliseconds: 100),
                            onDismissed: (direction) => _viewModel.onDismiss(
                              _tabController.index,
                              tasks[index].id,
                            ),
                            child: ListTile(
                              title: Text(tasks[index].title),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, top: 4),
                                child: Text(tasks[index].description),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date, bool isShown) {
    return Visibility(
      visible: isShown,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Colors.deepPurpleAccent, Colors.deepPurple]),
          color: Colors.deepPurple.shade300,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          DateFormat("dd MMM yyyy").format(date),
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
    );
  }

  Widget _buildDialog() {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                "An error occurred, please try again later.",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("Ok"),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _subscribeToViewModel() {
    _viewModel.isError.listen((event) {
      if (_isError) return;
      setState(() {
        _isError = true;
      });
      showAdaptiveDialog(
        context: context,
        builder: (context) => PopScope(
          onPopInvoked: (didPop) => setState(() {
            _isError = false;
          }),
          child: _buildDialog(),
        ),
      );
    }).addTo(compositeSubscription);
  }
}
