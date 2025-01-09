import socket
import threading


def handle_client(client_socket):
    try:
        while True:
            data = client_socket.recv(1024)
            if not data:
                break
            print(f"receive data: {data}")
    except Exception as e:
        print(f"error while handling socket data: {e}")
        client_socket.close()


def start_server(listen_host='0.0.0.0', listen_port=12345):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((listen_host, listen_port))
    server.listen(5)  # max connection

    print(f"server is listening on {listen_host}:{listen_port}")

    try:
        while True:
            client_sock, addr = server.accept()
            print(f"connection from {addr}")
            client_handler = threading.Thread(
                target=handle_client,
                args=(client_sock,)
            )
            client_handler.start()
    except KeyboardInterrupt:
        print("server is closing...")
    finally:
        server.close()


if __name__ == "__main__":
    start_server()



