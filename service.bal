import ballerinax/github;
import ballerina/http;

configurable string gitToken = ?;

type Repository record {|
    string repoName;
    int repoStars;
|};



# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get getTopStars(string gitOrg = "", int topStars = 5) returns Repository[]|error {
        // Send a response back to the caller.
        return getTop(gitOrg, topStars);
    }
}

function getTop(string gitOrg, int topStars) returns Repository[]|error {

    github:Client githubEp = check new (config = {
        auth: {
            token: gitToken
        }
    });

    stream<github:Repository,github:Error?> response = check githubEp->getRepositories(gitOrg, true);
    Repository []? topStarsList = check from github:Repository repo in response
     order by repo.stargazerCount descending
     limit topStars
     select {repoName: repo.name, repoStars: repo.stargazerCount ?:0};

    return topStarsList?:[];

}
