const info = document.getElementById('info');


function init() {
    var account = localStorage.getItem('account');

    var url = new URL('/balance.py', window.location.origin);
    url.searchParams.append('account', account);

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.statusText);
            }
            return response.text();
        })
        .then(data => {
	    info.innerText = data;
        })
        .catch((error) => {
            alert('Error: ' + error.message);
        });
}


init();
