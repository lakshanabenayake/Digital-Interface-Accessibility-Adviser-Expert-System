# HOW TO RUN

## 1. Required Software

- SWI-Prolog 9.0 or later: <https://www.swi-prolog.org/Download.html>
- A modern browser such as Firefox, Chrome, or Edge
- PowerShell, Git Bash, or another terminal

The required HTTP, JSON, and testing libraries are included with SWI-Prolog. No database, Node.js package, or internet connection is required to run the system. Internet access is useful for opening the reference links shown in the results.

## 2. Installation

1. Download and install SWI-Prolog.
2. When the installer offers the option, allow it to add `swipl` to the system PATH.
3. Extract or copy the complete project into a folder.
4. Keep the original folder structure. In particular, keep `web/` beside `web_server.pl`.
5. Open PowerShell or a terminal in the project folder.

To confirm that SWI-Prolog is available, run:

```text
swipl --version
```

If this prints a version number, the installation is ready.

## 3. Starting the System

### Direct SWI-Prolog Command

The system can also be started directly:

```text
swipl -q -s web_server.pl -- 8080
```

### Windows PowerShell

Open PowerShell in the project folder and run:

```powershell
.\run.ps1
```

### Git Bash, macOS, or Linux

Open a terminal in the project folder and run:

```bash
bash run.sh
```

Keep the terminal open while using the system. Open this address in a browser:

<http://localhost:8080/>

Press **Ctrl+C** in the terminal to stop the server.

## 4. Using Another Port

If port 8081 is already being used, choose another port.

Windows PowerShell example:

```powershell
.\run.ps1 -Port 8081
```

Git Bash, macOS, or Linux example:

```bash
bash run.sh 8081
```

Then open <http://localhost:8081/>.

## 5. How to Use the Adviser

1. Start the system and open its local browser address.
2. Under **Choose an interface type**, select Website/Web application, Desktop application, or Mobile application.
3. Inspect the interface that you want to review.
4. Under **Describe the interface**, answer whether each listed feature is present.
5. Under **Check what you observed**, answer each accessibility question with Yes, No, or Not sure.
6. Use **Not sure** whenever you have not verified an answer. The system will mark that item as needing review instead of treating it as a pass.
7. Select **Show results**.
8. Read the status, explanation, suggested action, and source link for each criterion.
9. The **Backward-chaining proof** automatically checks the first possible issue. Its numbered steps show the goal, selected rule, required premises, and conclusion.
10. To check another criterion, choose it under **Criterion to prove** and select **Run backward chaining**.
11. Expand **Show the forward-chaining rule trace** to see the conclusions produced from the supplied facts.
12. Select **Clear answers** before beginning a different review.

## 6. Understanding the Results

| Result | Meaning |
| --- | --- |
| Possible issue | The check applies and the supplied answer triggered an issue rule. |
| No issue reported | The check applies and the answer did not trigger its issue rule. |
| Not applicable | The required interface feature or platform capability is absent. |
| Needs review | The system does not have enough verified information to decide. |

Each possible issue includes a rule identifier, reasoning, a suggested action, and a source. These results support a preliminary review. They do not replace a complete accessibility audit.

## 7. Example

Review a desktop application with interactive controls:

1. Select **Desktop application**.
2. Answer Yes for **Interactive functions**.
3. Answer Yes for **Platform keyboard service**.
4. Answer No for **2.1.1 Keyboard** if an applicable function cannot be operated with the keyboard.
5. Select **Show results**.

Expected conclusion:

```text
Status: Possible issue
Criterion: 2.1.1 Keyboard
Rule: r09
Reason: The criterion applies and keyboard operation was answered No.
Suggested action: Provide keyboard operation for every applicable function.
```

The forward trace shows how the observations produced the finding. A backward proof for criterion 2.1.1 shows the interface type, feature conditions, platform support, and failing answer that support rule `r09`.

## 8. Running the Automated Tests

### Windows PowerShell

```powershell
.\test.ps1
```

### Git Bash, macOS, or Linux

```bash
bash test.sh
```

The successful test run reports 18 passed test definitions. The tests cover all 20 issue rules, fact and rule counts, applicability, uncertain answers, forward chaining, backward chaining, and source identifiers.

## 9. Troubleshooting

### `swipl` is not recognized or command not found

Install SWI-Prolog, allow the installer to add it to PATH, and restart the terminal. Then run `swipl --version` again.

### PowerShell blocks `run.ps1`

Use the direct command below from the project folder:

```text
swipl -q -s web_server.pl -- 8080
```

### The terminal reports a socket or port error

Choose a different port as described in Section 4.

### The browser cannot connect

Confirm that the terminal server is still running and that the browser uses the same port shown in the command.

### The questions or page do not load correctly

Confirm that the project was copied completely and that the `web/` folder remains beside `web_server.pl`.

## 10. Closing the System

Return to the terminal running the server and press **Ctrl+C**. The browser tab can then be closed.
