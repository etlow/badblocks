const statuses = { '-': true, '/': true };

const generateButton = document.getElementById('generate');
const generateButtonText = generateButton.innerText;
async function setGenerateButtonText(text) {
    generateButton.innerText = text ?? generateButtonText;
    await new Promise(r => setTimeout(r, 10));
}
generateButton.onclick = async function () {
    const blockSize = document.getElementById('bs').value;
    const logfile = document.getElementById('dd').value;
    const lines = logfile.split('\n')
        .filter(l => l[0] != '#') // ignore lines which are comments
        .filter((l, i) => i > 0) // ignore first line which is current pos
        .map(l => l.split(/\s+/)) // split by 3 columns
        .filter(vals => statuses[vals[2]]); // only want lines with those statuses
    const blocks = [];
    for (let i = 0; i < lines.length; i++) {
        if (i % 10000 == 0) {
            await setGenerateButtonText(`Generating ${i}/${lines.length}`);
        }
        const vals = lines[i];
        const startBlock = parseInt(vals[0], 16) / blockSize;
        const length = parseInt(vals[1], 16) / blockSize;
        for (let addr = startBlock; addr < startBlock + length; addr++) {
            blocks.push(addr);
        }
    }
    await setGenerateButtonText('Joining array');
    const output = blocks.join('\n') + '\n';

    await setGenerateButtonText('Displaying output');
    let displayText = output;
    if (output.length > 10000000) {
        displayText = 'truncated output preview below, actual length: '
            + output.length + ' characters\n\n' + output.slice(0, 200);
    }
    document.getElementById('bb').value = displayText;

    await setGenerateButtonText();
    const downloadLink = document.getElementById('download');
    const type = 'text/plain';
    downloadLink.href = URL.createObjectURL(new Blob([output], { type }));
    downloadLink.download = 'blocks.txt';
    downloadLink.innerText = 'Download text file';
}

