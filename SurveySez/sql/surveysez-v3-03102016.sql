/*
  New version of SurveySez tables - works with SurveySez version 3 - 03/10/2016
  
  * SEARCH AND REPLACE ON PREFIX wn16_
  
  * InputType ENUM added to questions
  
  * Status in surveys changed to ENUM data type.
  
  * TimesViewed in surveys replaced with TotalResponses.
  
  Here are a few notes on things below that may not be self evident:
  
  INDEXES: You'll see indexes below for example:
  
  INDEX SurveyID_index(SurveyID)
  
  Any field that has highly unique data that is either searched on or used as a join should be indexed, which speeds up a  
  search on a tall table, but potentially slows down an add or delete
  
  TIMESTAMP: MySQL currently only supports one date field per table to be automatically updated with the current time.  We'll use a 
  field in a few of the tables named LastUpdated:
  
  LastUpdated TIMESTAMP DEFAULT 0 ON UPDATE CURRENT_TIMESTAMP
  
  The other date oriented field we are interested in, DateAdded we'll do by hand on insert with the MySQL function NOW().
  
  CASCADES: In order to avoid orphaned records in deletion of a Survey, we'll want to get rid of the associated Q & A, etc. 
  We therefore want a 'cascading delete' in which the deletion of a Survey activates a 'cascade' of deletions in an 
  associated table.  Here's what the syntax looks like:  
  
  FOREIGN KEY (SurveyID) REFERENCES wn16_surveys(SurveyID) ON DELETE CASCADE
  
  The above is from the Questions table, which stores a foreign key, SurveyID in it.  This line of code tags the foreign key to 
  identify which associated records to delete.
  
  Be sure to check your cascades by deleting a survey and watch all the related table data disappear!
  
  
*/


SET foreign_key_checks = 0; #turn off constraints temporarily

#since constraints cause problems, drop tables first, working backward
DROP TABLE IF EXISTS wn16_responses_answers; 
DROP TABLE IF EXISTS wn16_responses;
DROP TABLE IF EXISTS wn16_answers;
DROP TABLE IF EXISTS wn16_questions;
DROP TABLE IF EXISTS wn16_surveys;
  
#all tables must be of type InnoDB to do transactions, foreign key constraints
CREATE TABLE wn16_surveys(
SurveyID INT UNSIGNED NOT NULL AUTO_INCREMENT,
AdminID INT UNSIGNED DEFAULT 0,
Title VARCHAR(255) DEFAULT '',
Description TEXT DEFAULT '',
DateAdded DATETIME,
LastUpdated TIMESTAMP DEFAULT 0 ON UPDATE CURRENT_TIMESTAMP,
TotalResponses INT DEFAULT 0,
Status ENUM('new','active','pending','retired') DEFAULT 'new',
PRIMARY KEY (SurveyID)
)ENGINE=INNODB; 

#assigning first survey to AdminID == 1
INSERT INTO wn16_surveys values (NULL,1,'Our First Survey','Description of Survey',NOW(),NOW(),0,'new');
INSERT INTO wn16_surveys values (NULL,1,'A Python Related Survey','Our second survey',NOW(),NOW(),0,'new');
INSERT INTO wn16_surveys values (NULL,1,'Yet a third survey','Are we gluttons for punishment?',NOW(),NOW(),0,'new');

#foreign key field must match size and type, hence SurveyID is INT UNSIGNED
CREATE TABLE wn16_questions(
QuestionID INT UNSIGNED NOT NULL AUTO_INCREMENT,
SurveyID INT UNSIGNED DEFAULT 0,
Question TEXT DEFAULT '',
Description TEXT DEFAULT '',
InputType ENUM('checkbox','radio','select','text') DEFAULT 'radio',
DateAdded DATETIME,
LastUpdated TIMESTAMP DEFAULT 0 ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (QuestionID),
INDEX SurveyID_index(SurveyID),
FOREIGN KEY (SurveyID) REFERENCES wn16_surveys(SurveyID) ON DELETE CASCADE
)ENGINE=INNODB;

#Questions below are associated with 3 surveys - InputType added to questions

INSERT INTO wn16_questions values (NULL,1,'Do You Like Our Website?','We really want to know!','radio',NOW(),NOW());
INSERT INTO wn16_questions values (NULL,1,'Do You Like Cookies?','We like cookies!','select',NOW(),NOW());
INSERT INTO wn16_questions values (NULL,1,'Favorite Toppings?','We like chocolate!','checkbox',NOW(),NOW());

#these are the questions for survey 2 (q4-5)
INSERT INTO wn16_questions VALUES (NULL,2,'Do You like ice cream?','We really want to know!','radio',NOW(),NOW());
INSERT INTO wn16_questions VALUES (NULL,2,'Which Flavor do you prefer?','We really want to know!','radio',NOW(),NOW());

#these are the questions for survey 3 (q6-7)
INSERT INTO wn16_questions VALUES (NULL,3,'Who is your favorite weather person?','We really want to know!','radio',NOW(),NOW());
INSERT INTO wn16_questions VALUES (NULL,3,'Who would you like to see for president?','We really want to know!','radio',NOW(),NOW());


CREATE TABLE wn16_answers(
AnswerID INT UNSIGNED NOT NULL AUTO_INCREMENT,
QuestionID INT UNSIGNED DEFAULT 0,
Answer TEXT DEFAULT '',
Description TEXT DEFAULT '',
DateAdded DATETIME,
LastUpdated TIMESTAMP DEFAULT 0 ON UPDATE CURRENT_TIMESTAMP,
Status INT DEFAULT 0,
PRIMARY KEY (AnswerID),
INDEX QuestionID_index(QuestionID),
FOREIGN KEY (QuestionID) REFERENCES wn16_questions(QuestionID) ON DELETE CASCADE
)ENGINE=INNODB;

#Answers below are associated with 8 questions

INSERT INTO wn16_answers values (NULL,1,'Yes','',NOW(),NOW(),0);
INSERT INTO wn16_answers values (NULL,1,'No','',NOW(),NOW(),0);

INSERT INTO wn16_answers values (NULL,2,'Yes','',NOW(),NOW(),0);
INSERT INTO wn16_answers values (NULL,2,'No','',NOW(),NOW(),0);
INSERT INTO wn16_answers values (NULL,2,'Maybe','',NOW(),NOW(),0);

INSERT INTO wn16_answers values (NULL,3,'Chocolate','',NOW(),NOW(),0);
INSERT INTO wn16_answers values (NULL,3,'Butterscotch','',NOW(),NOW(),0);
INSERT INTO wn16_answers values (NULL,3,'Pineapple','',NOW(),NOW(),0);

#these are answers for question 4
INSERT INTO wn16_answers VALUES (NULL,4,'Yes','',NOW(),NOW(),0);
INSERT INTO wn16_answers VALUES (NULL,4,'No','',NOW(),NOW(),0);

#these are answers for question 5
INSERT INTO wn16_answers VALUES (NULL,5,'Strawberry','',NOW(),NOW(),0);
INSERT INTO wn16_answers VALUES (NULL,5,'Vanilla','',NOW(),NOW(),0);
INSERT INTO wn16_answers VALUES (NULL,5,'Chocolate','',NOW(),NOW(),0);


#these are answers for question 6
INSERT INTO wn16_answers VALUES (NULL,6,'Steve Poole','',NOW(),NOW(),0);   
INSERT INTO wn16_answers VALUES (NULL,6,'Jeff Renner','',NOW(),NOW(),0);
INSERT INTO wn16_answers VALUES (NULL,6,'Andy Wapler','',NOW(),NOW(),0);   

#these are answers for question 7
INSERT INTO wn16_answers VALUES (NULL,7,'Hilary Clinton','',NOW(),NOW(),0);   
INSERT INTO wn16_answers VALUES (NULL,7,'Donald Trump','',NOW(),NOW(),0);                                                                         
INSERT INTO wn16_answers VALUES (NULL,7,'Stephen Colbert','',NOW(),NOW(),0);

CREATE TABLE wn16_responses(
ResponseID INT UNSIGNED NOT NULL AUTO_INCREMENT,
SurveyID INT UNSIGNED NOT NULL DEFAULT 0,
DateAdded DATETIME,
PRIMARY KEY (ResponseID),
INDEX SurveyID_index(SurveyID),
FOREIGN KEY (SurveyID) REFERENCES wn16_surveys(SurveyID) ON DELETE CASCADE
)ENGINE=INNODB;

#do one insert for each response here - the integer is which survey is being responded to

#here are 5 responses to survey 1
INSERT INTO wn16_responses VALUES (NULL,1,NOW());
INSERT INTO wn16_responses VALUES (NULL,1,NOW());
INSERT INTO wn16_responses VALUES (NULL,1,NOW());
INSERT INTO wn16_responses VALUES (NULL,1,NOW());
INSERT INTO wn16_responses VALUES (NULL,1,NOW());

#here are 3 responses to survey 2
INSERT INTO wn16_responses VALUES (NULL,2,NOW());
INSERT INTO wn16_responses VALUES (NULL,2,NOW());
INSERT INTO wn16_responses VALUES (NULL,2,NOW());



CREATE TABLE wn16_responses_answers(
RQID INT UNSIGNED NOT NULL AUTO_INCREMENT,
ResponseID INT UNSIGNED DEFAULT 0,
QuestionID INT DEFAULT 0,
AnswerID INT DEFAULT 0,
PRIMARY KEY (RQID),
INDEX ResponseID_index(ResponseID),
FOREIGN KEY (ResponseID) REFERENCES wn16_responses(ResponseID) ON DELETE CASCADE
)ENGINE=INNODB;

#there must be one block of choices for each surveyu - at least one per question
#also the first int is the Response ID, the second is the question, the third is the answer

#responses to survey #1, questions 1-3, answers 1-8
INSERT INTO wn16_responses_answers VALUES (NULL,1,1,1);
INSERT INTO wn16_responses_answers VALUES (NULL,1,2,4);
INSERT INTO wn16_responses_answers VALUES (NULL,1,3,7);
INSERT INTO wn16_responses_answers VALUES (NULL,1,3,8);

INSERT INTO wn16_responses_answers VALUES (NULL,2,1,1);
INSERT INTO wn16_responses_answers VALUES (NULL,2,2,5);
INSERT INTO wn16_responses_answers VALUES (NULL,2,3,6);
INSERT INTO wn16_responses_answers VALUES (NULL,2,3,7);
INSERT INTO wn16_responses_answers VALUES (NULL,2,3,8);

INSERT INTO wn16_responses_answers VALUES (NULL,3,1,2);
INSERT INTO wn16_responses_answers VALUES (NULL,3,2,5);
INSERT INTO wn16_responses_answers VALUES (NULL,3,3,8);

INSERT INTO wn16_responses_answers VALUES (NULL,4,1,2);
INSERT INTO wn16_responses_answers VALUES (NULL,4,2,5);
INSERT INTO wn16_responses_answers VALUES (NULL,4,3,8);

INSERT INTO wn16_responses_answers VALUES (NULL,5,1,2);
INSERT INTO wn16_responses_answers VALUES (NULL,5,2,5);
INSERT INTO wn16_responses_answers VALUES (NULL,5,3,8);

#responses to survey #2, questions 4 & 5, answers 9-13
INSERT INTO wn16_responses_answers VALUES (NULL,6,4,9);
INSERT INTO wn16_responses_answers VALUES (NULL,6,5,11);

INSERT INTO wn16_responses_answers VALUES (NULL,7,4,10);
INSERT INTO wn16_responses_answers VALUES (NULL,7,5,12);
INSERT INTO wn16_responses_answers VALUES (NULL,7,5,13);

INSERT INTO wn16_responses_answers VALUES (NULL,8,4,10);
INSERT INTO wn16_responses_answers VALUES (NULL,8,5,11);
INSERT INTO wn16_responses_answers VALUES (NULL,8,5,13);



SET foreign_key_checks = 1; #turn foreign key check back on
