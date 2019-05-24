// 执行Helm的方法
def helmDeploy(Map args) {
    if(args.init){
        println "Helm 初始化"
        sh "helm init --client-only --stable-repo-url ${args.url}"
    } else if (args.dry_run) {
        println "尝试 Helm 部署，验证是否能正常部署"
        sh "helm upgrade --install ${args.name} --namespace ${args.namespace} ${args.values} --set ${images},${tag} stable/${args.template} --dry-run --debug"
    } else {
        println "正式 Helm 部署"
        sh "helm upgrade --install ${args.name} --namespace ${args.namespace} ${args.values} --set ${images},${tag} stable/${args.template}"
    }
}

// jenkins slave 执行流水线任务
timeout(time: 600, unit: 'SECONDS') {
    try{
        def label = "jnlp-agent"
        podTemplate(label: label,cloud: 'kubernetes' ){
            node (label) {
                stage('Git阶段'){
                    echo "Git 阶段"
                    git branch: "master" ,changelog: true , url: "https://github.com/my-dlq/springboot-helloworld.git"
                }
                stage('Maven阶段'){
                    echo "Maven 阶段"
                    container('maven') {
                        //这里引用上面设置的全局的 settings.xml 文件，根据其ID将其引入并创建该文件
                        configFileProvider([configFile(fileId: "75884c5a-4ec2-4dc0-8d87-58b6b1636f8a", targetLocation: "settings.xml")]){
                            sh "mvn clean install -Dmaven.test.skip=true --settings settings.xml"
                        }
                    }
                }
                stage('Docker阶段'){
                    echo "Docker 阶段"
                    container('docker') {
                        // 读取pom参数
                        echo "读取 pom.xml 参数"
                        pom = readMavenPom file: './pom.xml'
                        // 设置镜像仓库地址
                        hub = "registry.cn-shanghai.aliyuncs.com"
                        // 设置仓库项目名
                        project_name = "mydlq"
                        echo "编译 Docker 镜像"
                        docker.withRegistry("http://${hub}", "ffb3b544-108e-4851-b747-b8a00bfe7ee0") {
                            echo "构建镜像"
                            // 设置推送到aliyun仓库的mydlq项目下，并用pom里面设置的项目名与版本号打标签
                            def customImage = docker.build("${hub}/${project_name}/${pom.artifactId}:${pom.version}")
                            echo "推送镜像"
                            customImage.push()
                            echo "删除镜像"
                            sh "docker rmi ${hub}/${project_name}/${pom.artifactId}:${pom.version}" 
                        }
                    }
                }
                stage('Helm阶段'){
                    container('helm-kubectl') {
                        withKubeConfig([credentialsId: "8510eda6-e1c7-4535-81af-17626b9575f7",serverUrl: "https://kubernetes.default.svc.cluster.local"]) {
                            // 设置参数
                            images = "image.repository=${hub}/${project_name}/${pom.artifactId}"
        		            tag = "image.tag=${pom.version}"
        		            template = "spring-boot"
        		            repo_url = "http://chart.mydlq.club"
        		            app_name = "${pom.artifactId}"
        		            // 检测是否存在yaml文件
        		            def values = ""
        		            if (fileExists('values.yaml')) {
        		                values = "-f values.yaml"
        		            }
        		            // 执行 Helm 方法
                            echo "Helm 初始化"
                            helmDeploy(init: true ,url: "${repo_url}");
                            echo "Helm 执行部署测试"
                            helmDeploy(init: false ,dry_run: true ,name: "${app_name}" ,namespace: "mydlqcloud" ,image: "${images}" ,tag: "${tag}" , values: "${values}" ,template: "${template}")
                            echo "Helm 执行正式部署"
                            helmDeploy(init: false ,dry_run: false ,name: "${app_name}" ,namespace: "mydlqcloud",image: "${images}" ,tag: "${tag}" , values: "${values}" ,template: "${template}")
                        }
                    }
                }
            }
        }
    }catch(Exception e) {
        currentBuild.result = "FAILURE"
    }finally {
        // 获取执行状态
        def currResult = currentBuild.result ?: 'SUCCESS' 
        // 判断执行任务状态，根据不同状态发送邮件
        stage('email'){
            if (currResult == 'SUCCESS') {
                echo "发送成功邮件"
                emailext(subject: '任务执行成功',to: '3*****7@qq.com',body: '''任务已经成功构建完成...''')
            }else {
                echo "发送失败邮件"
                emailext(subject: '任务执行失败',to: '3*****7@qq.com',body: '''任务执行失败构建失败...''')
            }
        }
    }
}