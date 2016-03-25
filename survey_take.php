<?php
/**
 * survey_take3.php allows us to take a existing survey, and see the result
 * 
 * This is a test page to prove the concept of displaying a form to allow a user to 
 * take a Survey, and immediately see the current Results
 *
 * survey_take2.php uses transactions to guarantee all data enters the DB as a single unit
 *
 * survey_take3.php passes all data insertion into the Survey Object
 *
 * @package SurveySez
 * @author Bill Newman <williamnewman@gmail.com>
 * @version 2.0 2010/08/11
 * @link http://www.billnsara.com/advdb/  
 * @license http://opensource.org/licenses/osl-3.0.php Open Software License ("OSL") v. 3.0
 * @see Survey_inc.php
 * @todo none
 */
require '../inc_0700/config_inc.php'; #provides configuration, pathing, error handling, db credentials 
spl_autoload_register('MyAutoLoader::NamespaceLoader');//required to load SurveySez namespace objects
#currently 'hard wired' to one survey - will need to pass in #id of a Survey on the qstring 
$mySurvey = new SurveySez\MY_Survey(1);
if($mySurvey->isValid)
{
	$PageTitle = "Take the '" . $mySurvey->Title . "' Survey!";
}else{
	$PageTitle = THIS_PAGE; #use constant 
}

//END CONFIG AREA ---------------------------------------------------------- 
get_header(); #defaults to header_inc.php
?>
<h3 align="center"><?php echo $PageTitle; ?></h3>
<p>In this page we'll test whether or not we can take a Survey and view the 
current results. (SurveySez version 4)</p>
<p>In version 2 of this page we add transactions.</p>
<p>In version 3 of this page we encapsulate data insertion into a static method of the Survey class.</p>
<?php

# public static method for entering response data
if(SurveySez\MY_Survey::insertSurvey())
{#Survey inserted! - show result
	$myResult = new SurveySez\Result(1);   # We have hard wired our survey ID to the first survey
	$PageTitle = $myResult->Title . " survey result";  //re-title page
	echo "Survey Title: <b>" . $myResult->Title . "</b><br />";  //show data on page
	echo "Survey Description: " . $myResult->Description . "<br />";
	echo "Number of Responses: " .$myResult->TotalResponses . "<br /><br />";
	$myResult->showGraph(); # showGraph method shows all questions, answers visual results!
	echo '<br /><a href="' . THIS_PAGE . '">Take Survey Again!</a>';
	$config->benchNote = "Data Inserted";
}else{# show form!
	if($mySurvey->isValid)
	{ #check to see if we have a valid SurveyID
		echo "Survey Title: <b>" . $mySurvey->Title . "</b><br />";  //show data on page
		echo "Survey Description: " . $mySurvey->Description . "<br />";
		$mySurvey->Form() . "<br />";	# Form() method creates form with questions
		$config->benchNote = "Form Displayed";
	}else{
		echo "Sorry, no such survey!";	
	}
}

get_footer(); #defaults to footer_inc.php 
?>
