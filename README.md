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

I have not added any filters. I think that correct solution is to filter request on the server side. It looks like that your API allows to filter results, but I have no documentation for it.
I have mocked submitting review API. There is header which contains "X-Auth-Token" field. It allows server to determine user (if we use JWT. In other case we should add parameter "userId" to the body). There are also several parameters in the body - they contain review's' data. 
