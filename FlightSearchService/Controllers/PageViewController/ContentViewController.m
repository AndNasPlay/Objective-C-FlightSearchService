//
//  ContentViewController.m
//  FlightSearchService
//
//  Created by Андрей Щекатунов on 09.08.2021.
//

#import "ContentViewController.h"

@interface ContentViewController ()

	@property (nonatomic, strong) UIImageView *imageView;
	@property (nonatomic, strong) UILabel *titleLable;
	@property (nonatomic, strong) UILabel *contentLable;

@end

@implementation ContentViewController

- (instancetype)init {

	self = [super init];
	if (self) {
		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 150.0, [UIScreen mainScreen].bounds.size.height / 2 - 300.0, 300.0, 300.0)];
		self.imageView.contentMode = UIViewContentModeScaleAspectFill;
		self.imageView.layer.cornerRadius = 8.0;
		self.imageView.clipsToBounds = YES;
		[self.view addSubview:self.imageView];

		self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100.0, CGRectGetMinY(self.imageView.frame) - 61.0, 200.0, 21.0)];
		self.titleLable.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightHeavy];
		self.titleLable.numberOfLines = 0;
		self.titleLable.textAlignment = NSTextAlignmentCenter;
		[self.view addSubview:self.titleLable];

		self.contentLable = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100.0, CGRectGetMaxY(self.imageView.frame) + 20.0, 200.0, 21.0)];
		self.contentLable.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
		self.contentLable.numberOfLines = 0;
		self.contentLable.textColor = UIColor.whiteColor;
		self.contentLable.textAlignment = NSTextAlignmentCenter;
		[self.view addSubview:self.contentLable];
	}
	return self;
}

- (void)setTitle:(NSString *)title {
	self.titleLable.text = title;
	float height = heightForText(title, self.titleLable.font, 200.0);
	self.titleLable.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100.0, CGRectGetMinY(self.imageView.frame) - 40.0 - height, 200.0, height);
}

- (void)setImage:(UIImage *)image {
	_image = image;
	self.imageView.image = image;
	self.imageView.backgroundColor = UIColor.clearColor;
}

- (void)setContentText:(NSString *)contentText {
	_contentText = contentText;
	self.contentLable.text = contentText;

	float height = heightForText(contentText, self.contentLable.font, 200.0);
	self.contentLable.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 100.0, CGRectGetMaxY(_imageView.frame) + 20.0, 200.0, height);
}

float heightForText(NSString *text, UIFont *font, float width) {
	if (text && [text isKindOfClass:[NSString class]]) {
		CGSize size = CGSizeMake(width, FLT_MAX);
		CGRect needLabel = [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:font} context:nil];
		return ceilf(needLabel.size.height);
	}
	return 0.0;
}


@end
