// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header(this.heading, {super.key});
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: const TextStyle(fontSize: 24),
        ),
      );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content, {super.key});
  final String content;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          content,
          style: const TextStyle(fontSize: 18),
        ),
      );
}

class IconAndDetail extends StatelessWidget {
  const IconAndDetail(this.icon, this.detail, {super.key});
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              detail,
              style: const TextStyle(fontSize: 18),
            )
          ],
        ),
      );
}

class StyledButton extends StatelessWidget {
  const StyledButton({required this.child, required this.onPressed, super.key});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.deepPurple)),
        onPressed: onPressed,
        child: child,
      );
}

class RepositoryLoader<T> extends StatelessWidget {
  final Logger _log = Logger();
  final Widget Function(
      BuildContext context, T result, CardsRepository repository) builder;

  final Future<T> Function(CardsRepository repository) fetcher;

  final Widget Function(Object e) errorWidgetBuilder;

  final Widget? indicatorWidget;

  final Widget? noDataWidget;

  RepositoryLoader(
      {required this.fetcher,
      required this.builder,
      this.errorWidgetBuilder = _defaultErrorWidget,
      this.indicatorWidget,
      this.noDataWidget});

  static Widget _defaultErrorWidget(Object e) =>
      Center(child: Text('Error: $e'));

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<CardsRepository>(context, listen: false);
    return FutureBuilder(
        future: fetcher(repository),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return indicatorWidget ??
                Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            _log.w('Error loading data',
                error: snapshot.error, stackTrace: snapshot.stackTrace);
            return errorWidgetBuilder(snapshot.error!);
          }
          if (!snapshot.hasData) {
            _log.d('No data for widget');
            return noDataWidget ?? Center(child: Text('No data'));
          }
          return builder(context, snapshot.data!, repository);
        });
  }
}

class BreadcrumbBar extends StatelessWidget {
  final List<String> breadcrumbs;
  final void Function(int index) onBreadcrumbTap;

  const BreadcrumbBar(
      {required this.breadcrumbs, required this.onBreadcrumbTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: breadcrumbs.asMap().entries.map((entry) {
        final index = entry.key;
        final title = entry.value;
        return GestureDetector(
          onTap: () => onBreadcrumbTap(index),
          child: Text(
            index == breadcrumbs.length - 1 ? title : '$title / ',
            style: index == breadcrumbs.length - 1
                ? TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
