/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTPullToRefreshViewComponentView.h"

#import <react/renderer/components/rncore/ComponentDescriptors.h>
#import <react/renderer/components/rncore/EventEmitters.h>
#import <react/renderer/components/rncore/Props.h>
#import <react/renderer/components/rncore/RCTComponentViewHelpers.h>

#import <React/RCTConversions.h>
#if !TARGET_OS_TV
#import <React/RCTRefreshableProtocol.h>
#endif
#import <React/RCTScrollViewComponentView.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;


#if TARGET_OS_TV

@implementation RCTPullToRefreshViewComponentView

@end

#else

@interface RCTPullToRefreshViewComponentView () <RCTPullToRefreshViewViewProtocol, RCTRefreshableProtocol>
@end

@implementation RCTPullToRefreshViewComponentView {
  UIRefreshControl *_refreshControl;
  RCTScrollViewComponentView *__weak _scrollViewComponentView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    // This view is not designed to be visible, it only serves UIViewController-like purpose managing
    // attaching and detaching of a pull-to-refresh view to a scroll view.
    // The pull-to-refresh view is not a subview of this view.
    self.hidden = YES;

    _props = PullToRefreshViewShadowNode::defaultSharedProps();

    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self
                        action:@selector(handleUIControlEventValueChanged)
              forControlEvents:UIControlEventValueChanged];
  }

  return self;
}

#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<PullToRefreshViewComponentDescriptor>();
}

- (void)updateProps:(const Props::Shared &)props oldProps:(const Props::Shared &)oldProps
{
  const auto &oldConcreteProps = static_cast<const PullToRefreshViewProps &>(*_props);
  const auto &newConcreteProps = static_cast<const PullToRefreshViewProps &>(*props);

  if (newConcreteProps.refreshing != oldConcreteProps.refreshing) {
    if (newConcreteProps.refreshing) {
      [_refreshControl beginRefreshing];
    } else {
      [_refreshControl endRefreshing];
    }
  }

  BOOL needsUpdateTitle = NO;

  if (newConcreteProps.title != oldConcreteProps.title) {
    needsUpdateTitle = YES;
  }

  if (newConcreteProps.titleColor != oldConcreteProps.titleColor) {
    needsUpdateTitle = YES;
  }

  if (needsUpdateTitle) {
    [self _updateTitle];
  }

  [super updateProps:props oldProps:oldProps];
}

#pragma mark -

- (void)handleUIControlEventValueChanged
{
  static_cast<const PullToRefreshViewEventEmitter &>(*_eventEmitter).onRefresh({});
}

- (void)_updateTitle
{
  const auto &concreteProps = static_cast<const PullToRefreshViewProps &>(*_props);

  if (concreteProps.title.empty()) {
    _refreshControl.attributedTitle = nil;
    return;
  }

  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  if (concreteProps.titleColor) {
    attributes[NSForegroundColorAttributeName] = RCTUIColorFromSharedColor(concreteProps.titleColor);
  }

  _refreshControl.attributedTitle =
      [[NSAttributedString alloc] initWithString:RCTNSStringFromString(concreteProps.title) attributes:attributes];
}

#pragma mark - Attaching & Detaching

- (void)didMoveToWindow
{
  if (self.window) {
    [self _attach];
  } else {
    [self _detach];
  }
}

- (void)_attach
{
  if (_scrollViewComponentView) {
    [self _detach];
  }

  _scrollViewComponentView = [RCTScrollViewComponentView findScrollViewComponentViewForView:self];
  if (!_scrollViewComponentView) {
    return;
  }

  if (@available(macCatalyst 13.1, *)) {
    _scrollViewComponentView.scrollView.refreshControl = _refreshControl;
  }
}

- (void)_detach
{
  if (!_scrollViewComponentView) {
    return;
  }

  // iOS requires to end refreshing before unmounting.
  [_refreshControl endRefreshing];

  if (@available(macCatalyst 13.1, *)) {
    _scrollViewComponentView.scrollView.refreshControl = nil;
  }
  _scrollViewComponentView = nil;
}

#pragma mark - Native commands

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTPullToRefreshViewHandleCommand(self, commandName, args);
}

- (void)setNativeRefreshing:(BOOL)refreshing
{
  if (refreshing) {
    [_refreshControl beginRefreshing];
  } else {
    [_refreshControl endRefreshing];
  }
}

#pragma mark - RCTRefreshableProtocol

- (void)setRefreshing:(BOOL)refreshing
{
  [self setNativeRefreshing:refreshing];
}

#pragma mark -

- (NSString *)componentViewName_DO_NOT_USE_THIS_IS_BROKEN
{
  return @"RefreshControl";
}

@end

#endif // TARGET_OS_TV

Class<RCTComponentViewProtocol> RCTPullToRefreshViewCls(void)
{
  return RCTPullToRefreshViewComponentView.class;
}
