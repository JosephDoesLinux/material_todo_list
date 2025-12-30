<?php
include 'connection.php';

$id = $_POST['id'];

$sql = "DELETE FROM tasks WHERE id = $id";

if ($con->query($sql) === TRUE) {
    echo json_encode(array("success" => true));
} else {
    echo json_encode(array("success" => false, "error" => $con->error));
}

$con->close();
?>
