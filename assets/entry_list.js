'use struct';

const displayItems = (respstr) => {
    const items = JSON.parse(respstr);
    const base = document.getElementById('entry-list');
    const template = document.getElementById('list-item-templ');

    base.innerHTML = '';

    items['entry'].forEach((e) => {
        const clone = document.importNode(template.content, true);
        const fields = clone.querySelectorAll('span');
        fields[0].textContent = e['name'];
        fields[1].textContent = e['date'];
        clone.querySelector('a').href = e['url'];
        base.appendChild(clone);
    });
}

let page;

const load = () => {
    const xhr = new XMLHttpRequest;
    xhr.open('GET', '/api/entry/list/lifo/' + page);
    xhr.addEventListener('load', () => {
        displayItems(xhr.responseText);
    });
    xhr.send();
}

addEventListener('load', () => {
    page = location.hash.match(/^#[0-9]+$/) ? parseInt(location.hash.substring(1)) : 0;
    load();

    document.getElementById('prev-page').addEventListener('click', () => {
        if (page <= 0) return;
        --page;
        load();
        location.hash = '#' + page;
    });
    document.getElementById('next-page').addEventListener('click', () => {
        ++page;
        load();
        location.hash = '#' + page;
    });
});
