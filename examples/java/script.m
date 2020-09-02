% Including .jar file in the java path
javaaddpath('MavenProject\target\HelloWorld-1.jar')
javaclasspath()

% Executing the main function of the App class
import com.example.*
App.main('')

% Removing the .jar file from the java path
javarmpath('MavenProject\target\HelloWorld-1.jar')