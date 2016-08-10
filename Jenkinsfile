#!groovy

node {
    def linkProductRepo = true
    def repoBase = 'https://github.com/Guite/'
    def projectName = 'MostGenerator'
    def repoUrl = repoBase + projectName + '/'
    def downstreamJobs = ['MOST-3_Build-Products']
    def artifacts = '**/releng/**/target/repository/**'

    def builder, postProcessor
    stage 'Init'
    fileLoader.withGit("${repoBase}MostProduct.git", 'master', 'c568f590-e3fe-4732-9e5c-68ebc55b849e') {
        builder = fileLoader.load('vars/builder')
        postProcessor = fileLoader.load('vars/postBuild')
    }

    try {
        builder.init(projectName, repoUrl, linkProductRepo)

        postProcessor.finish(repoUrl, artifacts, downstreamJobs);
    } catch (exception) {
        builder.handleError(repoUrl, exception)
        throw exception
    } finally {
        if (null != postProcessor) {
            postProcessor.finalise()
        }
    }
}
