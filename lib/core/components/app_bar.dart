import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



AppBar buildBlurredAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.transparent,
    // Transparent AppBar
    flexibleSpace: ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    ),
    elevation: 0,
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );
}

// AppBar buildBlurredUserAppBar(BuildContext context, String title) {
//   return AppBar(
//     backgroundColor: Colors.transparent,
//     // Transparent AppBar
//     toolbarHeight: 70.h,
//     flexibleSpace: ClipRRect(
//       borderRadius: BorderRadius.only(
//         bottomLeft: Radius.circular(15.r),
//         bottomRight: Radius.circular(15.r),
//       ),
//       child: Stack(
//         fit: StackFit.expand, // Ensures the blur effect spans the full AppBar
//         children: [
//           BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
//             child: Container(
//               color: Colors.transparent, // Fully transparent to reveal blur
//             ),
//           ),
//         ],
//       ),
//     ),
//     elevation: 0,
//     centerTitle: false,
//     title: _buildUserProfileRow(context),
//     actions: [
//       _buildNotificationIcon(CacheHelper.getData(key: 'userType'), context),
//     ],
//   );
// }
//
// _buildUserProfileRow(BuildContext context) {
//   var userType = CacheHelper.getData(key: 'userType');
//   return Column(
//     children: [
//       ConditionalBuilder(
//         condition: getit<MyAccountCubit>().clientProfile != null &&
//             userType == 'client',
//         builder: (BuildContext context) => UserProfileRow(
//           imageUrl:
//               getit<MyAccountCubit>().clientProfile!.data!.account!.photo ??
//                   "https://api.ymtaz.sa/uploads/person.png",
//           name: getit<MyAccountCubit>().clientProfile!.data!.account!.name!,
//           color: getColor(getit<MyAccountCubit>()
//               .clientProfile!
//               .data!
//               .account!
//               .currentRank!
//               .borderColor!),
//           image: getit<MyAccountCubit>()
//               .clientProfile!
//               .data!
//               .account!
//               .currentRank!
//               .image!,
//         ),
//         fallback: (BuildContext context) => const SizedBox(),
//       ),
//       ConditionalBuilder(
//         condition: getit<MyAccountCubit>().userDataResponse != null &&
//             userType == 'provider',
//         builder: (BuildContext context) => UserProfileRow(
//           isVerified:
//               getit<MyAccountCubit>().userDataResponse!.data!.account!.hasBadge,
//           imageUrl:
//               getit<MyAccountCubit>().userDataResponse!.data!.account!.photo ??
//                   "https://api.ymtaz.sa/uploads/person.png",
//           name:
//               '${getit<MyAccountCubit>().userDataResponse!.data!.account!.name}',
//           color: getColor(getit<MyAccountCubit>()
//               .userDataResponse!
//               .data!
//               .account!
//               .currentRank!
//               .borderColor!),
//           image: getit<MyAccountCubit>()
//               .userDataResponse!
//               .data!
//               .account!
//               .currentRank!
//               .image!,
//         ),
//         fallback: (BuildContext context) => const SizedBox(),
//       ),
//       ConditionalBuilder(
//         condition: userType == 'guest',
//         builder: (BuildContext context) => UserProfileRow(
//           imageUrl:
//               "https://e7.pngegg.com/pngimages/141/425/png-clipart-user-profile-computer-icons-avatar-profile-s-free-angle-rectangle-thumbnail.png",
//           name: "ضيفنا الكريم",
//           color: appColors.primaryColorYellow,
//           image: "https://api.ymtaz.sa/uploads/ranks/BrownShield.svg",
//         ),
//         fallback: (BuildContext context) => const SizedBox(),
//       ),
//     ],
//   );
// }
//
// Widget _buildNotificationIcon(String userType, BuildContext context) {
//   if (userType != 'client' && userType != 'provider') {
//     return const SizedBox.shrink();
//   }
//
//   final unreadCountNotifier =
//       getit<NotificationCubit>().unreadCount; // Notification counter
//
//   return Stack(
//     children: [
//       IconButton(
//         onPressed: () => context.pushNamed(Routes.notifications),
//         icon: Icon(
//           CupertinoIcons.bell_circle,
//           size: 30.sp,
//           color: appColors.blue100,
//         ),
//       ),
//       ValueListenableBuilder<int>(
//         valueListenable: unreadCountNotifier,
//         builder: (context, count, child) {
//           if (count > 0) {
//             return Positioned(
//               top: 5,
//               right: 5,
//               child: Badge(
//                 label: Text(count.toString()),
//                 backgroundColor: appColors.red,
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     ],
//   );
// }
