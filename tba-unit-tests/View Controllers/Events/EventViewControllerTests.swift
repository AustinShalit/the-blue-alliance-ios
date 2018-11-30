import XCTest
@testable import The_Blue_Alliance

class EventViewControllerTests: TBATestCase {

    var event: Event {
        return eventViewController.event
    }

    var eventViewController: EventViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        let event = insertDistrictEvent()

        eventViewController = EventViewController(event: event, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: eventViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        viewControllerTester = nil
        navigationController = nil
        eventViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        verifyLayer(viewControllerTester.window.layer)

        // MyTBA authed
        myTBA.authToken = "abcd123"
        verifyLayer(viewControllerTester.window.layer, identifier: "mytba")
    }

    func test_subscribableModel() {
        XCTAssertEqual(eventViewController.subscribableModel as? Event, event)
    }

    func test_delegates() {
        XCTAssertNotNil(eventViewController.infoViewController.delegate)
        XCTAssertNotNil(eventViewController.teamsViewController.delegate)
        XCTAssertNotNil(eventViewController.rankingsViewController.delegate)
        XCTAssertNotNil(eventViewController.matchesViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(eventViewController.title, "2018 Kettering University #1 District")
    }

    func test_showsInfo() {
        XCTAssert(eventViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is EventInfoViewController
        }))
    }

    func test_showsTeams() {
        XCTAssert(eventViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is TeamsViewController
        }))
    }

    func test_showsRankings() {
        XCTAssert(eventViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is EventRankingsViewController
        }))
    }

    func test_showsMatches() {
        XCTAssert(eventViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MatchesViewController
        }))
    }

    func test_info_pushesAlliances() {
        eventViewController.showAlliances()

        XCTAssert(navigationController.pushedViewController is EventAlliancesContainerViewController)
        let alliancesViewController = navigationController.pushedViewController as! EventAlliancesContainerViewController
        XCTAssertEqual(alliancesViewController.event, event)
    }

    func test_info_pushesAwards() {
        eventViewController.showAwards()

        XCTAssert(navigationController.pushedViewController is EventAwardsContainerViewController)
        let awardsViewController = navigationController.pushedViewController as! EventAwardsContainerViewController
        XCTAssertEqual(awardsViewController.event, event)
        XCTAssertNil(awardsViewController.teamKey)
    }

    func test_info_pushesDistrictPoints() {
        eventViewController.showDistrictPoints()

        XCTAssert(navigationController.pushedViewController is EventDistrictPointsContainerViewController)
        let districtPointsViewController = navigationController.pushedViewController as! EventDistrictPointsContainerViewController
        XCTAssertEqual(districtPointsViewController.event, event)
    }

    func test_info_pushesStats() {
        eventViewController.showStats()

        XCTAssert(navigationController.pushedViewController is EventStatsContainerViewController)
        let statsViewController = navigationController.pushedViewController as! EventStatsContainerViewController
        XCTAssertEqual(statsViewController.event, event)
    }

}