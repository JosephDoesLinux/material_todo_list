<?php
include 'connection.php';

$id = $_POST['id'];
$title = $_POST['title'];
$details = $_POST['details'];
$is_completed = $_POST['is_completed'];

$sql = "UPDATE tasks SET title = '$title', details = '$details', is_completed = $is_completed WHERE id = $id";

if ($con->query($sql) === TRUE) {
    echo json_encode(array("success" => true));
} else {
    echo json_encode(array("success" => false, "error" => $con->error));
}

$con->close();
?>
