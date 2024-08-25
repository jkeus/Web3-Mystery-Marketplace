var viewAllButton = document.getElementById('all');
viewAllButton.addEventListener('click', viewA);

var viewMineButton = document.getElementById('mine');
viewMineButton.addEventListener('click', viewM);

var p = document.getElementById('info');

function viewA() {
    var url = new URL('/view/view_all.py', window.location.origin);
    url.searchParams.append('account', localStorage.getItem('account'));
    url.searchParams.append('password', localStorage.getItem('password'));

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.statusText);
            }
            return response.text();
        })
        .then(data => {
	    const dataArray = data.substring(1, data.length - 1).split(", ");
	    
	    let outputString = "";
	for (let i = 0; i < dataArray.length; i += 2) {
		  const id = dataArray[i];
  		const price = parseFloat(dataArray[i + 1]) / 1000000000;
  		outputString += `id: ${id}<br>price: ${price} Gwei<br><br>`;
	}

	    p.innerHTML = outputString;

        })
        .catch((error) => {
            alert('Error: ' + error.message);
        });

}

function viewM() {
    var url = new URL('/view/view_mine.py', window.location.origin);
    url.searchParams.append('account', localStorage.getItem('account'));
    url.searchParams.append('password', localStorage.getItem('password'));

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.statusText);
            }
            return response.text();
        })
        .then(data => {
            const origs = data;
	    const replacedString = origs.replace(/<d>/g, "<br><br>");
	    p.innerHTML = replacedString;
        })
        .catch((error) => {
            alert('Error: ' + error.message);
        });

}

if (localStorage.getItem('account')) {
    document.getElementById('p').textContent = 'Account Logged In: ' + localStorage.getItem('account');
} else {
    document.getElementById('p').textContent = 'No Login';
}



