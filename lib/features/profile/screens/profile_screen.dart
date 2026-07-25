import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/profile/provider/user_stat_provider.dart';
import 'package:tenkai/features/profile/widgets/add_stat_form.dart';
import 'package:tenkai/features/profile/widgets/update_stat_form.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userStatState = ref.watch(userStatProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: TenkaiAppBar(
        title: 'Profile',
        showBackButton: false,
        actions: [
          TenkaiAppBarAction(
            symbol: 'plus',
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => SizedBox(
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.all(TenkaiSpacing.lg),
                  child: Center(child: AddStatForm()),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (userStatState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (userStatState.userStats != null) {
            final userStats = userStatState.userStats!;
            return ListView.builder(
              padding: EdgeInsets.only(
                top:
                    MediaQuery.of(context).padding.top +
                    TenkaiAppBar.compactHeight,
              ),
              itemCount: userStats.length,
              itemBuilder: (_, index) => GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => SizedBox(
                    height: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(TenkaiSpacing.lg),
                      child: Center(
                        child: UpdateStatForm(userStat: userStats[index]),
                      ),
                    ),
                  ),
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(TenkaiSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userStats[index].title),
                        Text(
                          '${userStats[index].value} ${userStats[index].unit}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Text('Something Went wrong');
          }
        },
      ),
    );
  }
}
