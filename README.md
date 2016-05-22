GYG challenge task

Installation:

Pods are included to the git. Just download, open GYGChallenge.xcworkspace and run.

Comments:

There are several tests for model objects. A couple of them are failing because of mocked response for 
- loadCurrentUserReviewWithCompletion ...
and
- createReview
functions.
Remove mock code and tests will pass.
