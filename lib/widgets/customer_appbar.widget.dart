import 'package:flutter/material.dart';
import 'package:ghodaa/screens/map_location_picker.screen.dart';
import 'package:ghodaa/services/color.service.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:provider/provider.dart';

class CustomerAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomerAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64.0); // Height of the AppBar

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Consumer<MainState>(
      builder: (context, mainState, child) {
        // Color backgroundColor = mainState.isPickUpLocationSet()
        //     ? ColorService().red
        //     : ColorService().green;

        return AppBar(
          backgroundColor: ColorService().black,
          leading: _buildLeadingButton(mainState),
          actions: [_buildActionButton(mainState)],
          title: _buildSearchBar(context, mainState),
        );
      },
    );
  }
}

Widget _buildLeadingButton(MainState mainState) {
  if (mainState.isDropOffLocationSet()) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: ColorService().white,
      ), // Menu icon
      onPressed: () {
        mainState.resetDropOffLocation();
      },
    );
  }

  if (mainState.isPickUpLocationSet()) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: ColorService().white,
      ), // Menu icon
      onPressed: () {
        mainState.resetPickUpLocation();
      },
    );
  }

  return IconButton(
    icon: Icon(
      Icons.menu,
      color: ColorService().white,
    ), // Menu icon
    onPressed: () {
      // Handle menu button press
    },
  );
}

Widget _buildSearchBar(BuildContext context, MainState mainState) {
  if (mainState.isDropOffLocationSet()) {
    return Text(
      'Ride Overview',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: ColorService().white,
      ),
    );
  }

  return SizedBox(
    height: 52,
    child: TextField(
      style: TextStyle(color: ColorService().white),
      decoration: InputDecoration(
        hintText: mainState.isPickUpLocationSet()
            ? 'Drop off address'
            : 'Pick up address',
        hintStyle: TextStyle(color: ColorService().grey, fontSize: 16.0),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: ColorService().grey,
        ),
      ),
      onTap: () async {
        Map<String, dynamic>? pickedLocation = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapLocationPicker(),
          ),
        );
        // inspect(pickedLocation);
        mainState.setRecommendationVisibility(true);
      },
    ),
  );
}

Widget _buildActionButton(MainState mainState) {
  if (mainState.isRecommendationVisible() ||
      mainState.isPickUpLocationSet() ||
      mainState.isDropOffLocationSet()) {
    return IconButton(
      icon: const Icon(
        Icons.close,
        color: Colors.white,
      ), // Menu icon
      onPressed: () {
        mainState.resetPickUpLocation();
        mainState.resetDropOffLocation();
        mainState.setRecommendationVisibility(false);
      },
    );
  }

  return IconButton(
    icon: const Icon(
      Icons.person,
      color: Colors.white,
    ), // Menu icon
    onPressed: () {
      // Handle menu button press
    },
  );
}
