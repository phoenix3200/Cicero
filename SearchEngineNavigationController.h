



@interface SearchEngineNavigationController : UINavigationController <UITableViewDataSource>
{
	id _controllerDelegate;
	
	UITableViewController* tvc;
}

+ (id) sharedNavigationController;

@end