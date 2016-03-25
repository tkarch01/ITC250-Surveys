<?php
/**
 * survey_take2.php allows us to take a existing survey, and see the result
 * 
 * This is a test page to prove the concept of displaying a form to allow a user to 
 * take a Survey, and immediately see the current Results
 *
 * survey_take2.php uses transactions to guarantee all data enters the DB as a single unit
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
<?php
	
	if(isset($_POST['SurveyID']) && (is_numeric($_POST['SurveyID'])))
	{//insert response!
		$iConn = IDB::conn();
		
		// turn off auto-commit
		mysqli_autocommit($iConn, FALSE);

		//insert response
		$sql = sprintf("INSERT into  " . PREFIX . "responses(SurveyID,DateAdded) VALUES ('%d',NOW())",$_POST['SurveyID']);
		$result = @mysqli_query($iConn,$sql); //moved or die() below!
		
		if(!$result)
		{// if error, roll back transaction
			mysqli_rollback($iConn);
			die(trigger_error("Error Entering Response: " . mysqli_error($iConn), E_USER_ERROR));
		}  
		
		//retrieve responseid
		$ResponseID = mysqli_insert_id($iConn); //get ID of last record inserted
		
		if(!$result)
		{// if error, roll back transaction
			mysqli_rollback($iConn);
			die(trigger_error("Error Retrieving ResponseID: " . mysqli_error($iConn), E_USER_ERROR));
		} 

		//loop through and insert answers
		foreach($_POST as $varName=> $value)
		{//add objects to collection
			 $qTest = substr($varName,0,2);  //check for "obj_" added to numeric type
			 if($qTest=="q_")
			 {//add choice!
			 	$QuestionID = substr($varName,2); //identify question
			 	
			 	if(is_array($_POST[$varName]))
			 	{//checkboxes are arrays, and we need to loop through each checked item to insert
				 	while (list ($key,$value) = @each($_POST[$varName])){
					 	$sql = "insert into  " . PREFIX . "responses_answers(ResponseID,QuestionID,AnswerID) values($ResponseID,$QuestionID,$value)";
				  		$result = @mysqli_query($iConn,$sql);
				  		if(!$result)
						{// if error, roll back transaction
							mysqli_rollback($iConn);
							die(trigger_error("Error Inserting Choice (array/checkbox): " . mysqli_error($iConn), E_USER_ERROR));
						} 
					}
		 		}else{//not an array, so likely radio or select
			 		$sql = "insert into  " . PREFIX . "responses_answers(ResponseID,QuestionID,AnswerID) values($ResponseID,$QuestionID,$value)";
			  	    $result = @mysqli_query($iConn,$sql);
			  	    if(!$result)
					{// if error, roll back transaction
						mysqli_rollback($iConn);
						die(trigger_error("Error Inserting Choice (single/radio): " . mysqli_error($iConn), E_USER_ERROR));
					} 
		 		}
			 }
		}

		//we got this far, lets COMMIT!
		mysqli_commit($iConn);
		
		// turn autocommit back on
		mysqli_autocommit($iConn, TRUE);
		
		//count total responses, update TotalResponses
		SurveySez\MY_Survey::responseCount($_POST['SurveyID']);
	//show results? (or thank you!!)
	$myResult = new SurveySez\Result(1);   //We have hard wired our survey ID to the first survey
	$PageTitle = $myResult->Title . " survey result";  //re-title page
	echo "Survey Title: <b>" . $myResult->Title . "</b><br />";  //show data on page
	echo "Survey Description: " . $myResult->Description . "<br />";
	echo "Number of Responses: " .$myResult->TotalResponses . "<br /><br />";
	$myResult->showGraph(); # showGraph method shows all questions, answers visual results!
	echo '<br /><a href="' . THIS_PAGE . '">Take Survey Again!</a>';

}else{//show form!
	if($mySurvey->isValid)
	{ #check to see if we have a valid SurveyID
		echo "Survey Title: <b>" . $mySurvey->Title . "</b><br />";  //show data on page
		echo "Survey Description: " . $mySurvey->Description . "<br />";
		$mySurvey->Form() . "<br />";	# Form() method creates form with questions
	}else{
		echo "Sorry, no such survey!";	
	}
}

get_footer(); #defaults to footer_inc.php 
?>
